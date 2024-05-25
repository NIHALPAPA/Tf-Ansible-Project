// To Generate Private Key
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Create Key Pair for Connecting EC2 via SSH
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

// Save PEM file locally
resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = var.key_name
}

# Define your resources, such as EC2 instances, S3 buckets, etc.
resource "aws_instance" "sudha-terraform" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.key_pair.key_name
  count = 2
  availability_zone = "us-east-1a"
  subnet_id     = aws_subnet.sudha_public_subnet_1.id # specify the subnet ID where instances will be launched
  security_groups = [aws_security_group.allow_web.id] # specify the security group(s) for the instance(s)

  tags = {
    Name = "sudha-terraform_${count.index + 1}"
  }
}

#security

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.sudha_vpc.id
  // Ingress rules (inbound traffic)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // allow traffic from anywhere
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // allow SSH from anywhere
  }

  // Egress rules (outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" // all protocols
    cidr_blocks = ["0.0.0.0/0"] // allow traffic to anywhere
  }
}



#vpc

resource "aws_vpc" "sudha_vpc" {
  cidr_block = "10.0.0.0/16" # specify the CIDR block for your VPC
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "sudha-vpc"
  }
}



#subnets

resource "aws_subnet" "sudha_public_subnet_1" {
  vpc_id            = aws_vpc.sudha_vpc.id # specify the ID of the existing VPC
  cidr_block        = "10.0.1.0/24"  # specify the CIDR block for the subnet
  availability_zone = "us-east-1a"   # specify the availability zone

  map_public_ip_on_launch = true  # enable auto-assign public IP addresses

  tags = {
    Name = "sudha_public-subnet-1"
  }
}

resource "aws_subnet" "sudha_public_subnet_2" {
  vpc_id            = aws_vpc.sudha_vpc.id # specify the ID of the existing VPC
  cidr_block        = "10.0.2.0/24"  # specify the CIDR block for the subnet
  availability_zone = "us-east-1b"   # specify the availability zone

  map_public_ip_on_launch = true  # enable auto-assign public IP addresses

  tags = {
    Name = "sudha_public-subnet-2"
  }
}

resource "aws_subnet" "sudha_private_subnet_1" {
  vpc_id            = aws_vpc.sudha_vpc.id # specify the ID of the existing VPC
  cidr_block        = "10.0.3.0/24"  # specify the CIDR block for the subnet
  availability_zone = "us-east-1a"   # specify the availability zone

  tags = {
    Name = "sudha_private-subnet-1"
  }
}

resource "aws_subnet" "sudha_private_subnet_2" {
  vpc_id            = aws_vpc.sudha_vpc.id # specify the ID of the existing VPC
  cidr_block        = "10.0.4.0/24"  # specify the CIDR block for the subnet
  availability_zone = "us-east-1b"   # specify the availability zone

  tags = {
    Name = "sudha_private-subnet-2"
  }
}



#routetable

resource "aws_route_table" "public_route_table_1" {
  vpc_id = aws_vpc.sudha_vpc.id # reference to the VPC ID

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sudha-igw.id # reference to the Internet Gateway ID
  }

  tags = {
    Name = "Sudha-rtb-public1-us-east-1a"
  }
}

resource "aws_route_table_association" "rts-sudha-public1" {
  subnet_id = aws_subnet.sudha_public_subnet_1.id
  route_table_id = aws_route_table.public_route_table_1.id
}

resource "aws_route_table" "public_route_table_2" {
  vpc_id = aws_vpc.sudha_vpc.id # reference to the VPC ID

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sudha-igw.id # reference to the Internet Gateway ID
  }

  tags = {
    Name = "Sudha-rtb-public2-us-east-1b"
  }
}

resource "aws_route_table_association" "rts-sudha-public2" {
  subnet_id = aws_subnet.sudha_public_subnet_2.id
  route_table_id = aws_route_table.public_route_table_2.id
}

resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.sudha_vpc.id # reference to the VPC ID

  tags = {
    Name = "Sudha-rtb-private1-us-east-1a"
  }
}

resource "aws_route_table_association" "rts-sudha-private1" {
  subnet_id = aws_subnet.sudha_private_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
  }

resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.sudha_vpc.id # reference to the VPC ID

  tags = {
    Name = "Sudha-rtb-private2-us-east-1b"
  }
}

resource "aws_route_table_association" "rts-sudha-private2" {
  subnet_id = aws_subnet.sudha_private_subnet_2.id
  route_table_id = aws_route_table.private_route_table_2.id  
}



#internet gateway

resource "aws_internet_gateway" "sudha-igw" {
  vpc_id = aws_vpc.sudha_vpc.id # reference to the VPC ID
  tags = {
    Name = "sudha-igw"
  }
}