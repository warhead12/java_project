data "aws_secretsmanager_secret" "db" {
  name = "onlinebookstore/db"
}


resource "aws_ecs_task_definition" "task" {
  family = "onlinebookstore-task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 512
  memory = 1024
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name = "app"
      image = "${aws_ecr_repository.repo.repository_url}:latest"

      portMappings = [
        {
          containerPort = 8080
        }
      ]

      # NON-SECRET VALUES
      environment = [
        { name = "DB_HOST", value = aws_db_instance.mysql.address },
        { name = "DB_PORT", value = "3306" },
        { name = "DB_NAME", value = var.db_name }
      ]

      # SECRETS FROM AWS SECRETS MANAGER
      secrets = [
        {
          name      = "DB_USER"
          valueFrom = "${data.aws_secretsmanager_secret.db.arn}:DB_USER::"
        },
        {
          name      = "DB_PASS"
          valueFrom = "${data.aws_secretsmanager_secret.db.arn}:DB_PASS::"
        }
      ]
    }
  ])
}
