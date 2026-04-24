#############################################
# outputs.tf
#
# PURPOSE:
# - Export key resource identifiers
# - Support validation, integration, and reuse
#############################################

# ------------------------
# Networking
# ------------------------

# VPC identifier
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# Subnet identifier
output "subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.main.id
}

# Security group identifier
output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.main.id
}

# ------------------------
# Compute
# ------------------------

# EC2 preprocess instance identifier
output "ec2_instance_id" {
  description = "Preprocessing EC2 instance ID"
  value       = aws_instance.preprocess.id
}

# ECS cluster identifier
output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

# ECS task definition identifier
output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.processor.arn
}

# ------------------------
# Orchestration
# ------------------------

# Step Functions state machine identifier
output "step_function_arn" {
  description = "Step Functions state machine ARN"
  value       = aws_sfn_state_machine.workflow.arn
}

# ------------------------
# Storage
# ------------------------

# S3 bucket used as workflow input
output "s3_bucket_name" {
  description = "Transaction input S3 bucket name"
  value       = aws_s3_bucket.transactions.bucket
}