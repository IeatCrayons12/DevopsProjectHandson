terraform {
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~>4.0"
        }
    }
    backend "s3"{
        key = "aws/ec2-deploy/terraform.tfstate"
    }
}

provider "aws" {
    region = var.region
}

resource "aws_instance" "server" {
    ami = "ami-052efd3df9dad4825"
    instance_type = "t2.micro"
    key_name = aws_key_pair.deployer.key_name 
    vpc_security_group_ids = [aws_security_group.maingroup.id]
    iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
    connection {
     type = "ssh"
     host = self.public_ip
     user = "ubuntu"
     private_key = var.private_key
     timeout = "4m"
    }
    tags = {
        "name" = "DeployVM"
    }
}

resource "aws_iam_instance_profile" "ec2-profile"{
    name = "ec2-profile"
    role = "forDevopsProject"

}

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


resource "aws_key_pair" "deployer" {
    key_name = "deployer-key"
    public_key = var.public_key
}

output "instance_public_ip" {
    value =aws_instance.server.public_ip
    sensitive = true
}