# ecs.tf - ECS Task Definition and Service
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/flask-app"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "flask" {
  family                   = "flask-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "flask-container",
      image     = "<your-docker-image-url>",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [{ containerPort = 5000, hostPort = 5000 }],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group = aws_cloudwatch_log_group.ecs_logs.name,
          awslogs-region = "us-east-1",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "flask" {
  name            = "flask-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.flask.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.flask.arn
    container_name   = "flask-container"
    container_port   = 5000
  }
}

