#############################################
# ecs.tf
#
# PURPOSE:
# - Define ECS infrastructure for batch processing
# - Tasks are executed synchronously by Step Functions
#############################################

# ECS cluster hosting Fargate tasks
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}

# ECS task definition for batch-style execution
resource "aws_ecs_task_definition" "processor" {
  # Logical task family name
  family = "${var.project_name}-processor"

  # Required for Fargate-based tasks
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  # Compute allocation for the task
  cpu    = var.ecs_task_cpu
  memory = var.ecs_task_memory

  # IAM roles used for image pull and task execution
  execution_role_arn = var.iam_role_arn
  task_role_arn      = var.iam_role_arn

  # Container definition for the batch processor
  container_definitions = jsonencode([
    {
      name      = "processor"
      image     = var.ecs_container_image
      essential = true

      # Simple placeholder command representing batch logic
      command = [
        "sh",
        "-c",
        "echo ECS task completed successfully && sleep 10"
      ]
    }
  ])
}
