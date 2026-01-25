resource "aws_ecs_cluster" "cluster" {
  name = "onlinebookstore-cluster"
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
      portMappings = [{
        containerPort = 8080
      }]
      environment = [
        { name = "DB_HOST", value = aws_db_instance.mysql.address },
        { name = "DB_PORT", value = "3306" },
        { name = "DB_NAME", value = var.db_name },
        { name = "DB_USER", value = var.db_user },
        { name = "DB_PASS", value = var.db_password }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name = "onlinebookstore-service"
  cluster = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets = [aws_subnet.public.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
