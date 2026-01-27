data "aws_secretsmanager_secret_version" "db" {
  secret_id = "onlinebookstore/db"
}

resource "aws_db_subnet_group" "dbsubnet" {
  name = "mysql-subnet-group"

  subnet_ids = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]
}

resource "aws_db_instance" "mysql" {
  engine         = "mysql"
  instance_class = "db.t3.micro"

  allocated_storage = 20

  username = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["DB_USER"]
  password = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["DB_PASS"]
  db_name  = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["DB_NAME"]

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.dbsubnet.name

  publicly_accessible = false
  skip_final_snapshot = true
}
