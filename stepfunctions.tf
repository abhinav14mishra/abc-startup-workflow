#############################################
# stepfunctions.tf
#
# PURPOSE:
# - Coordinate preprocessing and processing stages
# - Enforce EC2 health validation before ECS execution
# - Retry validation until EC2 becomes healthy
#############################################

resource "aws_sfn_state_machine" "workflow" {
  name     = var.step_function_name
  role_arn = var.iam_role_arn

  depends_on = [
    aws_instance.preprocess,
    aws_ecs_task_definition.processor
  ]

  definition = jsonencode({
    StartAt = "DescribeEC2"

    States = {

      ##################################
      # DescribeEC2
      #
      # Retrieves EC2 instance state and
      # health check information
      ##################################
      DescribeEC2 = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ec2:describeInstanceStatus"

        Parameters = {
          InstanceIds         = [aws_instance.preprocess.id]
          IncludeAllInstances = true
        }

        ResultPath = "$.ec2"
        Next       = "ValidateEC2"
      }

      ##################################
      # ValidateEC2
      #
      # Verifies EC2 readiness conditions
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

        # EC2 not ready yet → wait and retry
        Default = "WaitForEC2"
      }

      ##################################
      # WaitForEC2
      #
      # Allows EC2 health checks to complete
      ##################################
      WaitForEC2 = {
        Type    = "Wait"
        Seconds = 45
        Next    = "DescribeEC2"
      }

      ##################################
      # RunECSTask
      #
      # Executes ECS Fargate batch task
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
    }
  })
}
