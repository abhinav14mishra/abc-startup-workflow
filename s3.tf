#############################################
# s3.tf
#
# PURPOSE:
# - Provide S3 bucket for transaction input
# - Initiate workflow execution on object upload
#############################################

# S3 bucket used as the workflow entry point
resource "aws_s3_bucket" "transactions" {
  # Globally unique bucket name
  bucket = var.s3_bucket_name

  # Allow full cleanup during Terraform destroy
  force_destroy = true
}

# Enable S3 to send events to EventBridge
resource "aws_s3_bucket_notification" "eventbridge" {
  bucket      = aws_s3_bucket.transactions.id
  eventbridge = true
}

# EventBridge rule for S3 object creation events
resource "aws_cloudwatch_event_rule" "s3_trigger" {
  name = "${var.project_name}-s3-trigger"

  # Match object creation events for the target bucket
  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [
          aws_s3_bucket.transactions.bucket
        ]
      }
    }
  })
}

# EventBridge target to start the Step Functions workflow
resource "aws_cloudwatch_event_target" "stepfunction_target" {
  rule      = aws_cloudwatch_event_rule.s3_trigger.name
  target_id = "StartStepFunction"

  # Step Functions state machine ARN
  arn = aws_sfn_state_machine.workflow.arn

  # IAM role used by EventBridge to invoke Step Functions
  role_arn = var.iam_role_arn
}