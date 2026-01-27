############################
# ECS CLUSTER
############################

resource "aws_ecs_cluster" "cluster" {
  name = "onlinebookstore-cluster"
}

############################
# READ SECRET
############################

data "aws_secretsmanager_secret" "db" {
  name = "onlinebookstore/db"
}

############################
# TASK DEFINITION
############################

resource "aws_ecs_task_definition" "task" {
  family                   = "onlinebookstore-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "${aws_ecr_repository.repo.repository_url}:latest"

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      # LOGGING
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/onlinebookstore"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "app"
        }
      }

      ####################
      # NON-SECRET VARS
      ####################
      environment = [
        {
          name  = "DB_HOST"
          value = aws_db_instance.mysql.address
        },
        {
          name  = "DB_PORT"
          value = "3306"
        }
      ]

      ####################
      # SECRETS
      ####################
      secrets = [
        {
          name      = "DB_USER"
          valueFrom = "${data.aws_secretsmanager_secret.db.arn}:DB_USER::"
        },
        {
          name      = "DB_PASS"
          valueFrom = "${data.aws_secretsmanager_secret.db.arn}:DB_PASS::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${data.aws_secretsmanager_secret.db.arn}:DB_NAME::"
        }
      ]
    }
  ])
}

############################
# ECS SERVICE
############################

resource "aws_ecs_service" "service" {
  name            = "onlinebookstore-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
