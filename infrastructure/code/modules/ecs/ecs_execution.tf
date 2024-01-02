
resource "null_resource" "blogdemo_image" {
  provisioner "local-exec" {
    command     = <<EOT
        export DOCKER_DEFAULT_PLATFORM=linux/amd64
	      cd ../../../../application && mvn clean package -Dmaven.test.skip=true
        aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin 127745533311.dkr.ecr.${var.aws_region}.amazonaws.com
        docker buildx install
        docker buildx create --use
      	docker buildx build --no-cache --push --platform linux/amd64 -t ${aws_ecr_repository.blogdemo_ecr_image.repository_url}:latest .
        
    	
EOT
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }
  depends_on = [aws_ecr_repository.blogdemo_ecr_image]

}

resource "aws_iam_role" "task_role" {
  name = "blogtemo-${var.env_name}-blogdemotask-role"
  lifecycle {
    create_before_destroy = true
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess",
    "arn:aws:iam::aws:policy/AWSCloudMapReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    "arn:aws:iam::aws:policy/AutoScalingFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::${var.account_id}:policy/blogtemo-${var.env_name}-ECRRolePolicy"
  ]
  depends_on = [aws_iam_policy.ecr_task_role_policy]

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_task_execution_policy" {
  name        = "blogtemo-${var.env_name}-ECRTaskExecutionPolicy"
  description = "Allows ECS task to interact with ECR"

  lifecycle {
    create_before_destroy = true
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "ecr:GetAuthorizationToken",
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        "Sid" : "CloudWatchLogsPermissions",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
      },
      {
        "Sid" : "AppConfig",
        "Effect" : "Allow",
        "Action" : [
          "appconfig:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_task_role_policy" {
  name        = "blogtemo-${var.env_name}-ECRRolePolicy"
  description = "Allows ECS task to interact with ECR"
  lifecycle {
    create_before_destroy = true
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "ecr:GetAuthorizationToken",
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        "Sid" : "CloudWatchLogsPermissions",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
      },
      {
        "Sid" : "AppConfig",
        "Effect" : "Allow",
        "Action" : [
          "appconfig:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "task_execution_role" {
  name = "blogtemo-${var.env_name}-blogdemotask-execution-role"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess",
    "arn:aws:iam::aws:policy/AWSCloudMapReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    "arn:aws:iam::aws:policy/AutoScalingFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::${var.account_id}:policy/blogtemo-${var.env_name}-ECRTaskExecutionPolicy"
  ]
  depends_on = [aws_iam_policy.ecr_task_execution_policy]

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_secretsmanager_secret" "rds_external_secret" {
  name = var.rds_external_secret
}
data "aws_secretsmanager_secret_version" "my_secret_version" {
  secret_id     = data.aws_secretsmanager_secret.rds_external_secret.id
  version_stage = "AWSCURRENT"
}

resource "aws_ecs_task_definition" "demoapp_service_definition" {
  family                   = "${var.env_name}-demoapp-service-cluster-task"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  network_mode             = "awsvpc"
  cpu    = 4096
  memory = 8192


  container_definitions = jsonencode([
    {
      name   = "${var.env_name}-blogdemo-demoapp-service-container",
      image  = "${aws_ecr_repository.blogdemo_ecr_image.repository_url}:latest"
      cpu    = 512
      memory = 256
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      essential = true
      environment = [
        {
          name  = "AWS_DEFAULT_REGION"
          value = "eu-north-1"
        },
        {
          name  = "DEPLOY_ENV"
          value = "${var.env_name}"
        },
        {
          name  = "ENV_SCOPE"
          value = ""
        },

        {
          name  = "CONFIG_ENV"
          value = "${var.env_name}"
        },
        { name = "DATABASE_URL", value = "${var.rds_endpoint}" },
        { name = "DB_INDENTIFIER", value = "postgres" },
        { name = "SPRING_DATASOURCE_USERNAME", value = jsondecode(data.aws_secretsmanager_secret_version.my_secret_version.secret_string)["username"] },
        { name = "SPRING_DATASOURCE_PASSWORD", value = jsondecode(data.aws_secretsmanager_secret_version.my_secret_version.secret_string)["password"] }

      ]
      logConfiguration = {
        logDriver = "awslogs"
        
        options = {
          "awslogs-group"         = "/aws/ecs/demoappServiceLog"
          "awslogs-region"        = "eu-north-1"
          "awslogs-stream-prefix" = "blogdemo-service-log"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
        interval    = 30
        timeout     = 20
        retries     = 5
        startPeriod = 30
      }
    }
  ])
  depends_on = [aws_ecr_repository.blogdemo_ecr_image]
}


# Create an ECS service to run the existing task definition
resource "aws_ecs_service" "ecs_service" {
  name                               = "${var.env_name}-existing-blogdemo-demoapp"
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.demoapp_service_definition.arn
  launch_type                        = "FARGATE"
  desired_count                      = var.desired_service_count
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 50
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_launch_config_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn
    container_name   = "${var.env_name}-blogdemo-demoapp-service-container"
    container_port   = 8080
  }

}