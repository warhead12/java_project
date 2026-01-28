resource "aws_ecr_repository" "repo" {
  name         = "onlinebookstore"
  force_delete = true
}
  