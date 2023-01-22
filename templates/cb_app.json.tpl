[
  {
    "cpu": ${fargate_cpu},
    "essential": true,
    "image": "${app_image}",
    "memory": ${fargate_memory},
    "name": "${app_name}",
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ]
  }
]