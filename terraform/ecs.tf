resource "aws_ecs_cluster" "app" {
  name = "flask-app-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "flask-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "flask-container"
      image     = "<aws_account_number>.dkr.ecr.us-west-1.amazonaws.com/my-flask-app:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/flask-app"
          awslogs-region        = "eu-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
