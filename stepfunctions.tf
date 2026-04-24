#############################################
# stepfunctions.tf
#
# PURPOSE:
# - Coordinate preprocessing and processing stages
# - Enforce EC2 health validation before ECS execution
#############################################

resource "aws_sfn_state_machine" "workflow" {
  # Name of the Step Functions state machine
  name = var.step_function_name

  # IAM role assumed during workflow execution
  # Must allow EC2 describe, ECS runTask, and iam:PassRole
  role_arn = var.iam_role_arn

  # Ensure required compute resources exist
  depends_on = [
    aws_instance.preprocess,
    aws_ecs_task_definition.processor
  ]

  # State machine definition (Amazon States Language)
  definition = jsonencode({

    # Initial state
    StartAt = "DescribeEC2"

    States = {

      ##################################
      # DescribeEC2
      #
      # Fetches EC2 instance state and
      # system/instance health status
      ##################################
      DescribeEC2 = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ec2:describeInstanceStatus"

        Parameters = {
          InstanceIds          = [aws_instance.preprocess.id]
          IncludeAllInstances  = true
        }

        # Persist EC2 status response
        ResultPath = "$.ec2"
        Next       = "ValidateEC2"
      }

      ##################################
      # ValidateEC2
      #
      # Evaluates EC2 readiness conditions
      ##################################
      ValidateEC2 = {
        Type = "Choice"

        Choices = [{
          And = [
            {
              Variable     = "$.ec2.InstanceStatuses[0].InstanceState.Name"
              StringEquals = "running"
            },
            {
              Variable     = "$.ec2.InstanceStatuses[0].SystemStatus.Status"
              StringEquals = "ok"
            },
            {
              Variable     = "$.ec2.InstanceStatuses[0].InstanceStatus.Status"
              StringEquals = "ok"
            }
          ]
          Next = "RunECSTask"
        }]

        # Fail execution if validation criteria are not met
        Default = "EC2ValidationFailed"
      }

      ##################################
      # RunECSTask
      #
      # Executes ECS Fargate task and
      # waits for completion
      ##################################
      RunECSTask = {
        Type     = "Task"
        Resource = "arn:aws:states:::ecs:runTask.sync"

        Parameters = {
          LaunchType     = "FARGATE"
          Cluster        = aws_ecs_cluster.main.arn
          TaskDefinition = aws_ecs_task_definition.processor.arn

          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets        = [aws_subnet.main.id]
              SecurityGroups = [aws_security_group.main.id]
              AssignPublicIp = "ENABLED"
            }
          }
        }

        End = true
      }

      ##################################
      # EC2ValidationFailed
      #
      # Terminates workflow on failed
      # EC2 health validation
      ##################################
      EC2ValidationFailed = {
        Type  = "Fail"
        Error = "EC2NotHealthy"
        Cause = "EC2 instance failed required health checks"
      }
    }
  })
}