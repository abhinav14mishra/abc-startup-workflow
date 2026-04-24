#############################################
# ec2.tf
#
# PURPOSE:
# - Provision EC2 instance used for
#   preprocessing in the workflow
# - Acts as a prerequisite for ECS execution
#############################################

resource "aws_instance" "preprocess" {
  # AMI defining the base operating system
  ami = var.ec2_ami

  # Instance size selected for low-cost workloads
  instance_type = var.ec2_instance_type

  # Deploy instance into application subnet
  subnet_id = aws_subnet.main.id

  # Security group controlling network access
  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

  # Instance profile required to attach IAM role to EC2
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Resource identification tag
  tags = {
    Name = "${var.project_name}-preprocess-ec2"
  }
}