provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/builder_key.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "builder_key" {
  key_name   = "builder-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_security_group" "builder_sg" {
  name        = "builder-sg"
  description = "Allow SSH and HTTP access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<YOUR_IP>/32"]
  }

  ingress {
    description = "HTTP Flask"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["<YOUR_IP>/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "builder" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.builder_key.key_name
  vpc_security_group_ids = [aws_security_group.builder_sg.id]
  subnet_id     = "subnet-xxxxxxxx"
  tags = { Name = "builder" }
}

output "ssh_private_key_path" {
  value       = local_file.private_key.filename
  description = "Path to the SSH private key"
  sensitive   = true
}

output "public_ip" {
  value = aws_instance.builder.public_ip
}
