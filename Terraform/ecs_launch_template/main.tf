#####################
# Data required     #
#####################

data "template_file" "ecs_instance" {
  template = file("${path.module}/ecs_instance.sh")

  vars = {
    ecs_cluster             = var.cluster_name
    stack_name              = var.stack_name
    region                  = var.region
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn2-ami-ecs-hvm-*-x86_64-ebs",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

#####################
# ECS resources     #
#####################

resource "aws_iam_role" "this" {
  name = "${var.stack_name}_ecs_instance_role_${var.environment}"
  path = "/ecs/"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.stack_name}_ecs_instance_profile_ec2_${var.environment}"
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_s3_role" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_ses_role" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_security_group" "default-ecs" {
    vpc_id = var.vpc_id
    description = "default-ecs"
}

resource "aws_security_group_rule" "default-ecs"{
    depends_on = [ aws_security_group.default-ecs ]
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_group_id = aws_security_group.default-ecs.id
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow access from internet"
}

resource "aws_security_group_rule" "default-ecs2"{
    depends_on = [ aws_security_group.default-ecs ]
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_group_id = aws_security_group.default-ecs.id
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow access to internet"
}

resource "aws_launch_configuration" "ecs_launch_configuration" {
    depends_on = [ aws_security_group.default-ecs ]
    image_id = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    associate_public_ip_address = false
    iam_instance_profile = aws_iam_instance_profile.this.id
    key_name = var.key_name
    security_groups = [ aws_security_group.default-ecs.id ]
    root_block_device {
        volume_size = 50
        volume_type = "gp2"
    }

    user_data = data.template_file.ecs_instance.rendered
}

#ECS Instances Autoscalling Group
resource "aws_autoscaling_group" "stack-prod" {
    depends_on = [ aws_launch_configuration.ecs_launch_configuration ]

    name = format("ecs-%s-%s", var.stack_name, var.environment)
    vpc_zone_identifier = [ var.private_subnets[0], var.private_subnets[1] ]
    launch_configuration = aws_launch_configuration.ecs_launch_configuration.id
    min_size = var.min_instances_size
    max_size = var.max_instances_size
    desired_capacity = var.desired_instances_size
    lifecycle {
      create_before_destroy = true
    }
    
    tag {
      key                 = "Name"
      value               = "ECS-stack-prod"
      propagate_at_launch = true
    }
    
    tag {
      key                 = "project"
      value               = "stack-deploy"
      propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "ecs_policy_cpu" {
  name                   = "ecs-scaling-policy-cpu"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.stack-prod.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu-value-to-scale
    disable_scale_in = false
  }
}

resource "aws_autoscaling_policy" "ecs_policy_memory" {
  name                   = "ecs-scaling-policy-memory"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.stack-prod.name
  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = var.cluster_name
      }

      metric_name = "MemoryUtilization"
      namespace   = "AWS/ECS"
      statistic   = "Average"
    }
    target_value = var.cpu-value-to-scale
    disable_scale_in = false
  }
}



# Launch template ECS

resource "aws_launch_template" "ecs_launch_template" {
    depends_on = [ aws_security_group.default-ecs ]
    image_id = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type_template
    
    network_interfaces {
        associate_public_ip_address = false
        security_groups = concat(
            [aws_security_group.default-ecs.id],
        )
    }
    iam_instance_profile {
        name = aws_iam_instance_profile.this.id
    }

    key_name = var.key_name
    
    block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
            volume_size = 50
            volume_type = "gp2"
        }
    }

    user_data = base64encode(data.template_file.ecs_instance.rendered)
}

## ECS Instances Autoscalling Group
resource "aws_autoscaling_group" "stack-prod-template" {
    depends_on = [ aws_launch_template.ecs_launch_template ]

    name = format("ecs_%s_%s_template", var.stack_name, var.environment)
    vpc_zone_identifier = [ var.private_subnets[0], var.private_subnets[1] ]
    
    launch_template {
        id      = aws_launch_template.ecs_launch_template.id
        version = "$Latest"
    }

    min_size = "1"
    max_size = "2"
    desired_capacity = "2"
    lifecycle {
      create_before_destroy = true
    }
    
    tag {
      key                 = "Name"
      value               = "ECS-stack-prod"
      propagate_at_launch = true
    }
    
    tag {
      key                 = "project"
      value               = "stack-deploy"
      propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "ecs_policy_cpu_template" {
  name                   = "ecs-scaling-policy-cpu"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.stack-prod-template.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu-value-to-scale
    disable_scale_in = false
  }
}

resource "aws_autoscaling_policy" "ecs_policy_memory_template" {
  name                   = "ecs-scaling-policy-memory"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.stack-prod-template.name
  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = var.cluster_name
      }

      metric_name = "MemoryUtilization"
      namespace   = "AWS/ECS"
      statistic   = "Average"
    }
    target_value = var.cpu-value-to-scale
    disable_scale_in = false
  }
}