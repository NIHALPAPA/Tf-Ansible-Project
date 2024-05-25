# Define your resources, such as EC2 instances, S3 buckets, etc.
resource "aws_instance" "nihal-terraform" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = "HERO2"
  count = 2

  tags = {
    Name = "nihal-terraform_${count.index + 1}"
  }
}
