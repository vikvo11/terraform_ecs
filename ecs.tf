#----------------------------LoadBalancer

resource "aws_security_group" "lb" {
  name        = "example-alb-security-group"
  vpc_id      = module.vpc.aws_vpc_example.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "default" {
  name            = "example-lb"
  subnets         = module.vpc.aws_subnet_example.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "hello_world" {
  name        = "example-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.aws_vpc_example.id
  target_type = "ip"
}

resource "aws_lb_listener" "hello_world" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.hello_world.id
    type             = "forward"
  }
}
#-----------------------------------------ECS_TAKS


data "template_file" "cb_app" {
  template = file("./templates/cb_app.json.tpl")

  vars = {
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
    app_name     = var.app_name
  }
}

#------------------------------

resource "aws_security_group" "hello_world_task" {
  name        = "example-task-security-group"
  vpc_id      = module.vpc.aws_vpc_example.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.lb.id]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#"arn:aws:iam::743033304438:role/ecsTaskExecutionRole"
# resource "aws_ecs_task_definition" "example" {
#   family = "nginxdemos-hello-new"
#   task_role_arn         = aws_iam_role.ecs_task_execution_role.arn
#   execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = 1024
#   memory                   = 2048
#   container_definitions = <<DEFINITION
# [
#     {
#         "name": "nginxdemos",
#         "image": "nginxdemos/hello",
#         "cpu": 0,
#         "portMappings": [
#             {
#                 "containerPort": 80,
#                 "hostPort": 80,
#                 "protocol": "tcp"
#             }
#         ],
#         "essential": true
#     }
# ]
# DEFINITION
# }

# resource "aws_ecs_service" "example" {
#   name            = "nginxdemos-hello-service1"
#   cluster         = aws_ecs_cluster.example.arn
#   task_definition = aws_ecs_task_definition.example.arn
#   launch_type     = "FARGATE"
#   desired_count = 1
#   scheduling_strategy = "REPLICA"

#   network_configuration {
#     assign_public_ip = true
#     security_groups = [aws_security_group.hello_world_task.id]
#     subnets         = module.vpc.aws_subnet_example.*.id
#   }

#    load_balancer {
#     target_group_arn = aws_lb_target_group.hello_world.arn
#     container_name = "nginxdemos"
#     container_port = 80
#   }

#   depends_on = [aws_lb_listener.hello_world]
# }

resource "aws_ecs_task_definition" "app" {
  family                   = "cb-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn #aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.cb_app.rendered
}

resource "aws_ecs_service" "main" {
  name            = "cb-service"
  #cluster         = aws_ecs_cluster.main.id
  cluster         = aws_ecs_cluster.example.arn
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  # network_configuration {
  #   security_groups  = [aws_security_group.ecs_tasks.id]
  #   subnets          = aws_subnet.private.*.id
  #   assign_public_ip = true
  # }
  network_configuration {
    assign_public_ip = true
    security_groups = [aws_security_group.hello_world_task.id]
    subnets         = module.vpc.aws_subnet_example.*.id
  }

  # load_balancer {
  #   target_group_arn = aws_alb_target_group.app.id
  #   container_name   = "cb-app"
  #   container_port   = var.app_port
  # }
     load_balancer {
    target_group_arn = aws_lb_target_group.hello_world.arn
    container_name = "cb-app"
    container_port = var.app_port
  }

  #depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
  depends_on = [aws_lb_listener.hello_world]
}

# output "load_balancer_ip" {
#   value = aws_lb.default.dns_name
# }