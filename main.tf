provider "aws" {
  region = "us-east-1"
  // access_key = var.AWS_ACCESS_KEY
  // secret_key = var.AWS_SECRET_KEY
  access_key = var.AWS.ACCESS_KEY
  secret_key = var.AWS.SECRET_KEY
}

resource "aws_vpc" "hello-world-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "hello-world-vpc",
  }
}

resource "aws_internet_gateway" "hello-world-gw" {
  vpc_id = aws_vpc.hello-world-vpc.id

  tags = {
    Name = "hello-world-gw"
  }
}

resource "aws_route_table" "hello-world-rt" {
  vpc_id = aws_vpc.hello-world-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hello-world-gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.hello-world-gw.id
  }

  tags = {
    Name = "hello-world-route_table"
  }
}

resource "aws_subnet" "hello-world-subnet" {
  vpc_id     = aws_vpc.hello-world-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "hello-world-subnet"
  }
}

resource "aws_route_table_association" "hello-world-rta" {
  subnet_id      = aws_subnet.hello-world-subnet.id
  route_table_id = aws_route_table.hello-world-rt.id
}

resource "aws_security_group" "hello-world-sg" {
  name        = "allow_web_traffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.hello-world-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 2
    to_port          = 2
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "hello-world-sg"
  }
}

resource "aws_network_interface" "hello-world-ni" {
  subnet_id       = aws_subnet.hello-world-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.hello-world-sg.id]
}

resource "aws_eip" "hello-world-eip" {
  network_interface = aws_network_interface.hello-world-ni.id
  associate_with_private_ip = "10.0.1.50"
  vpc      = true

  depends_on = [
    aws_internet_gateway.hello-world-gw,
  ]
}

resource "aws_instance" "hello-world-ec2" {
  ami = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "my-key-pair"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.hello-world-ni.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c "echo your first web server > /var/www/html/index.html"
              EOF

  tags = {
    Name = "hello-world-ec2",
  }
}
