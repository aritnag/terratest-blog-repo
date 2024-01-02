
resource "aws_ecr_repository" "blogdemo_ecr_image" {
  name         = "${var.blogdemo_ecr_image}-${var.env_name}-repository"
  force_delete = true
}

resource "aws_ecr_repository_policy" "blogdemo_ecr_image" {
  repository = aws_ecr_repository.blogdemo_ecr_image.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the  repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}
