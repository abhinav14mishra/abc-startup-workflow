#############################################
# network.tf
#
# PURPOSE:
# - Provide networking foundation for compute resources
# - Enable controlled outbound internet access
#############################################

# Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
  # Primary CIDR block for the environment
  cidr_block = var.vpc_cidr

  # Required for DNS resolution and service discovery
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  # Attach gateway to the VPC
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public subnet
resource "aws_subnet" "main" {
  # Associate subnet with the VPC
  vpc_id = aws_vpc.main.id

  # CIDR block allocated to the subnet
  cidr_block = var.subnet_cidr

  # Automatically assign public IPs to launched resources
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-subnet"
  }
}

# Route table for public access
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Default route to the internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-rt"
  }
}

# Associate route table with public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

# Security group for application resources
resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id

  # Allow unrestricted traffic within the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow unrestricted outbound access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}