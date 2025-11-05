output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.builder.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.builder.id
}

output "ssh_private_key_path" {
  description = "Path to the generated private SSH key"
  value       = local_file.private_key.filename
  sensitive   = true
}

output "ssh_key_name" {
  description = "Name of the AWS SSH key pair"
  value       = aws_key_pair.builder_key.key_name
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.builder_sg.id
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_instance.builder.public_ip}"
}
