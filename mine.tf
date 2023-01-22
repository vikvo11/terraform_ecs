terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.50.0"
    }
  }
}

# variable "region" {
#   default = "us-east-1"
# }
# variable "availability_zones" {
#   default = ["us-east-1a", "us-east-1b"]
# }

provider "aws" {
  # Configuration options
  profile = "default"
  region  = var.aws_region #"us-east-1"

}

#-------MODULES------------------
#------------------VPC
module "vpc" {
  source = "./VPC"

  availability_zones = var.availability_zones
  region = var.aws_region
}

#----- Key and Log_Group
resource "aws_kms_key" "example" {
  description             = "example"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "example" {
  name = "example"
}




#--------------------AutoScalingGroup-----------



resource "aws_launch_configuration" "example" {
  image_id             = "ami-05e7fa5a3b6085a75" #"ami-0ff8a91507f77f867"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  instance_type        = "t2.micro"
  key_name             = "EC2 Tutorial"
  user_data            = <<-EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.example.name} >> /etc/ecs/ecs.config;
EOF
  security_groups      = [aws_security_group.ECS_SG_example.id]
}


resource "aws_autoscaling_group" "example" {

  launch_configuration = aws_launch_configuration.example.name

  min_size         = 1
  max_size         = 5
  desired_capacity = 1

  #vpc_zone_identifier = [aws_subnet.example[0].id, aws_subnet.example[1].id]
  vpc_zone_identifier = module.vpc.aws_subnet_example.*.id

  tag {
    key                 = "Name"
    value               = "example-asg"
    propagate_at_launch = true
  }
}
#-------------------ECS_Cluster
resource "aws_ecs_cluster" "example" {
  name = "ECS_Orchestration"
  #capacity_providers = ["FARGATE"]
  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.example.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.example.name
      }
    }
  }

}

resource "aws_ecs_cluster_capacity_providers" "example" {
  provider     = aws
  cluster_name = aws_ecs_cluster.example.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.example.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.example.name
  }
}

resource "aws_ecs_capacity_provider" "example" {
  name = "example"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.example.arn
  }
}
