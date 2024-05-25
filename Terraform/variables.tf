# Define variables
variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  default     = "us-east-1"
}

variable "key_name" {
  description = "Name of the SSH key pair"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-04b70fa74e45c3917"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  default     = "t2.micro"
}

