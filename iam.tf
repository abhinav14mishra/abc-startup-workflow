#############################################
# iam.tf
#
# PURPOSE:
# - Instance profile for EC2
#############################################

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = split("/", var.iam_role_arn)[1]
}
