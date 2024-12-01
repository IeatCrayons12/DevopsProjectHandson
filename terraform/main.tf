terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>4.0"
    }
  }

  backend "s3" {
    key = "aws/ec2-deploy/terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

# Key Pair for EC2 Instance
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

# EC2 Instance
resource "aws_instance" "server" {
  ami                    = "ami-047126e50991d067b"
  instance_type           = "t2.micro"
  subnet_id               = "subnet-098da2b1547225acf"  # Use your existing subnet ID
  key_name                = aws_key_pair.deployer.key_name
  vpc_security_group_ids  = [aws_security_group.maingroup.id]
  iam_instance_profile    = aws_iam_instance_profile.ec2-profile.name
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = var.private_key
    timeout     = "4m"
  }
  tags = {
    "Name" = "DeployVM"
  }
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = "forDevopsProject"
}

# Security Group
resource "aws_security_group" "maingroup" {
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    self        = false
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = false
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = false
  }
}

# Route Table for Public Subnet
# resource "aws_internet_gateway" "igw" {
#   vpc_id = "vpc-0f405f5a7c03d39b1"  # Your existing VPC ID
# }

resource "aws_route_table" "public_rt" {
  vpc_id = "vpc-0f405f5a7c03d39b1"  # Your existing VPC ID

  route {
    cidr_block = "0.0.0.0/0"  # Route all traffic to the IGW
    gateway_id = "igw-0551c54f95991bdd8"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = "subnet-098da2b1547225acf"  # Use your existing subnet ID
  route_table_id = aws_route_table.public_rt.id
}

output "instance_public_ip" {
  value     = aws_instance.server.public_ip
  sensitive = true
}

