# Terraform Setup for Flask Application Deployment on AWS ECS (Fargate)

This repository contains the Terraform configuration to deploy a Flask application to AWS using ECS (Fargate). The setup includes:

- **VPC with public and private subnets**
- **ECS Cluster** for container orchestration
- **ECR Repository** to store Docker images
- **ECS Task Definition** and **Service** for running the application in a container
- **IAM roles** and **Security Groups** for required permissions and network access
- **CloudWatch Logs** for logging

## Prerequisites

Before applying the Terraform configuration, ensure you have the following:

- **AWS CLI** configured with appropriate credentials.
- **Terraform** installed (recommended version: 1.x).
- An **ECR repository** for storing Docker images.

## AWS Resources Setup

### 1. **VPC Setup**

Terraform creates a VPC with the following components:

- **Public Subnet**: For resources that need to be publicly accessible.
- **Private Subnet**: For resources that need to be private and secure.
- **Internet Gateway**: For routing public traffic.
- **NAT Gateway**: To allow private subnets to access the internet.
- **Route Tables**: To manage traffic routing within the VPC.

### 2. **ECR Repository**

Terraform creates an Amazon Elastic Container Registry (ECR) repository to store Docker images. You must build and push your Docker image to this repository.

### 3. **ECS Cluster and Task Definition**

The ECS cluster will be set up with the Fargate launch type. The task definition is created with the following:

- **Flask Application**: The application is packaged into a Docker image and pushed to ECR.
- **IAM Role for ECS Task**: Provides necessary permissions to ECS tasks.

### 4. **ECS Service**

The ECS service runs the Flask application on Fargate, which is an AWS-managed container platform. The service ensures that the application is always running.

### 5. **Security Groups and IAM Roles**

Security groups will be created to control access to the ECS service, allowing traffic from the public internet (for web access) and internal communication between services.

IAM roles for ECS allow the task to access resources such as CloudWatch Logs and other AWS services.

### 6. **CloudWatch Logs**

CloudWatch Logs are configured to store logs from the ECS containers to help with monitoring and troubleshooting.

---

## Directory Structure

```plaintext
.
├── ecs-fargate
│   ├── main.tf                # Main Terraform configuration
│   ├── variables.tf           # Variables used in the configuration
│   ├── outputs.tf             # Outputs after the Terraform run
│   └── terraform.tfvars       # Terraform variables file (optional)
├── app
│   ├── Dockerfile             # Dockerfile for Flask app
│   └── requirements.txt       # Python dependencies for the Flask app
└── README.md                  # This file
Terraform Configuration
1. Provider Configuration
In main.tf, the AWS provider is configured to use your default AWS credentials:

hcl
provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

2. VPC Setup
Terraform creates a VPC with public and private subnets, and a NAT Gateway for private subnets to access the internet.

hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "flask-vpc"
  cidr = "10.0.0.0/16"
  azs  = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = true
}

3. ECR Repository
Define the ECR repository where the Flask Docker image will be stored.

hcl
resource "aws_ecr_repository" "flask_app" {
  name = "flask-app-repository"
}
4. ECS Cluster and Task Definition
Create the ECS cluster for Fargate and a task definition that will run the Docker image in a container.

hcl
resource "aws_ecs_cluster" "flask_cluster" {
  name = "flask-cluster"
}

resource "aws_ecs_task_definition" "flask_task" {
  family                = "flask-task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "256"
  memory                = "512"
  execution_role_arn    = aws_iam_role.ecs_execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name      = "flask-app"
    image     = "${aws_ecr_repository.flask_app.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
    }]
  }])
}
5. ECS Service
Deploy the Flask app in the ECS Fargate service.

hcl
resource "aws_ecs_service" "flask_service" {
  name            = "flask-service"
  cluster         = aws_ecs_cluster.flask_cluster.id
  task_definition = aws_ecs_task_definition.flask_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups = [aws_security_group.flask_sg.id]
    assign_public_ip = true
  }
}
6. IAM Roles for ECS
Create the IAM roles needed for ECS to execute tasks and interact with other AWS services.

hcl
resource "aws_iam_role" "ecs_execution_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Effect    = "Allow"
      Sid       = ""
    }]
  })
}
Usage
Initialize Terraform:

Run the following command to initialize the Terraform configuration:

bash
terraform init
Review the Execution Plan:

Run the following command to preview the resources Terraform will create:

bash
terraform plan
Apply the Configuration:

To create the resources in AWS, run:

bash
terraform apply
Push Docker Image to ECR:

After the infrastructure is set up, build and push your Docker image to ECR:

bash
docker build -t flask-app .
$(aws ecr get-login --no-include-email --region us-east-1)
docker tag flask-app:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/flask-app-repository:latest
docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/flask-app-repository:latest
Verify ECS Deployment:

Go to the AWS ECS console and ensure that the service is running with the Flask app.

Clean Up
To delete all the resources created by Terraform, run:

bash
terraform destroy
This will remove the VPC, ECS cluster, task definition, service, and other resources.

License
This repository is licensed under the MIT License. See the LICENSE file for more information.

markdown

### Notes:
- Replace `<AWS_ACCOUNT_ID>` with your AWS account ID.
- Modify `us-east-1` to your region if necessary.
- Ensure your IAM roles and security group permissions are appropriate for your environment.
