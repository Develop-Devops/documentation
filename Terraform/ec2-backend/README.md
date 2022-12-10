# ecs_launch_configuration

Esta es la configuración actual que tengo para ecs_launch_configuration. Esta ya ha empezado a estar en desuso por aws.

```
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
```

# ecs_launch_template

El equivalente para la configuración anterior sería asi

```
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
```