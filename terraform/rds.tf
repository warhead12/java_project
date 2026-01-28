############################
# READ DB SECRET
############################

data "aws_secretsmanager_secret_version" "db" {
  secret_id = "onlinebookstore/db"
}

############################
# DB SUBNET GROUP
############################

resource "aws_db_subnet_group" "dbsubnet" {
  name = "mysql-subnet-group"

  subnet_ids = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]
}

############################
# MYSQL DATABASE
############################

resource "aws_db_instance" "mysql" {

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  username = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["DB_USER"]
  password = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["DB_PASS"]
  db_name  = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["DB_NAME"]

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.dbsubnet.name

  publicly_accessible = false
  skip_final_snapshot = true

  backup_retention_period = 0
  deletion_protection     = false
}
