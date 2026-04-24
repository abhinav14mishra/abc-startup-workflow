#############################################
# variables.tf
#
# PURPOSE:
# - Central definition for all configurable inputs
# - Ensures consistency across environments
#############################################

# ------------------------
# General configuration
# ------------------------

# AWS region where all resources are created
variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

# Common prefix for naming and tagging resources
variable "project_name" {
  type    = string
  default = "abc-startup"
}

# ------------------------
# Networking configuration
# ------------------------

# CIDR block for the VPC
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# CIDR block for the public subnet
variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

# ------------------------
# EC2 (Pre-processing)
# ------------------------

# AMI ID for EC2 preprocess instance
variable "ec2_ami" {
  type    = string
  default = "ami-05d2d839d4f73aafb"
}

# EC2 instance type
variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

# ------------------------
# ECS (Processing)
# ------------------------

variable "ecs_cluster_name" {
  type    = string
  default = "abc-startup-cluster"
}

variable "ecs_task_cpu" {
  type    = string
  default = "256"
}

variable "ecs_task_memory" {
  type    = string
  default = "512"
}

variable "ecs_container_image" {
  type    = string
  default = "public.ecr.aws/nginx/nginx:stable"
}

# ------------------------
# IAM
# ------------------------

# Single IAM role reused across all services
variable "iam_role_arn" {
  type    = string
  default = "arn:aws:iam::165742852730:role/GitHubActions-IaC-Deployer"
}

# ------------------------
# Step Functions
# ------------------------

variable "step_function_name" {
  type    = string
  default = "abc-startup-workflow"
}

# ------------------------
# S3
# ------------------------

variable "s3_bucket_name" {
  type        = string
  default     = "2472737-usecase-bucket"
  description = "Bucket used to upload transaction files"
}
