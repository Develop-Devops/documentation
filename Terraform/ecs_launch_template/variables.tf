variable "environment" {
  
}

variable "instance_type" {
  
}


variable "profile" {
  default = "stack-ecs"
}

variable "cluster_name" {
  default = "stack-prod"
}

variable "min_instances_size" {
  default = "1"
}

variable "max_instances_size" {
  default = "100"
}


variable "desired_instances_size" {
  default = "3"
}

variable "cpu-value-to-scale" {
  default = "3"
}

variable "stack_name" {
  default = "stack"
}

variable "vpc_id" {
  default = "vpc-sdf43"
}


variable "private_subnets" {
  type = list
  default = [
    "subnet-dfgdf3",
    "subnet-dfgdf3"
  ]
}

variable "public_subnets" {
  type = list
  default = [
    "subnet-2423df",
    "subnet-655989"
  ]
}

variable "key_name" {
}

# variable "aws_lb_target_group" {
# }

variable "tags_ecs" {
  description = "A mapping of tags to assign"
  type        = map(string)
  default = {
      Name    = "stack-prod-server"
      Cluster = "stack-prod"
    }
}

variable "region" {
  
}

variable "instance_type_template" {
  
}