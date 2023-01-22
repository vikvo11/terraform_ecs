# variables.tf

# variable "region" {
#   default = "us-east-1"
# }
variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role Name"
  default = "myEcsAutoScaleRole"
}

variable "ecs_task_execution_role" {
  default = "arn:aws:iam::743033304438:role/ecsTaskExecutionRole"
  #arn:aws:iam::743033304438:role/ecsTaskExecutionRole"
}

variable "ecs_autoscale_role" {
  default = "aarn:aws:iam::743033304438:role/ecsAutoscaleRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "bradfordhamilton/crystal_blockchain:latest"
}
variable "app_name" {
  description = "container name"
  default     = "cb-app"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}