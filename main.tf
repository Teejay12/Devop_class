provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}
resource "aws_subnet" "public_subnet" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = "${aws_vpc.main.id}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public_subnet"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "private_subnet"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "main"
  }
}
resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "main"
  }
}
resource "aws_route_table_association" "public_route_table" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.r.id
}
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}
resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow https inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "http from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_https"
  }
}
resource "aws_instance" "jenkins" {
  ami                    = "ami-09a5b0b7edf08843d"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = aws_key_pair.daniel.key_name
  vpc_security_group_ids = [aws_security_group.allow_https.id, aws_security_group.allow_http.id]
  tags = {
    Name = "jenkins"
  }
}
resource "aws_instance" "tomcat" {
  ami                    = "ami-09a5b0b7edf08843d"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = aws_key_pair.daniel.key_name
  vpc_security_group_ids = ["sg-0f5a191e2ae3d1866", "sg-048cedbf2cd6681de"]
  tags = {
    Name = "tomcat"
  }
}
resource "aws_key_pair" "daniel" {
  key_name   = "daniel"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClsbR1WYsqJ0hiyDumK5qVqwHX7Ayps+owgqA4giO2gb/xblVsOa85dfEBmG075yK0g3skvxLRxJgPsRVAa2S0IN74COxdjUN/8GW1G+OI+Au4mdb5s713R+V5Qthkw8Eb5+iQvv25JihJ2zWm6NMa1DReSKjlc8aydx74AbhOiVcRGrLgJKAAO046Vbr8m8NDrJgGxVw2Ev/clvQMny3n+2mY9fHtBxpWtiQlCci69+5krD2YQ13GL4nn6sPrmFZlIvfpL8dp7dfPp+Ao6dUUW2Jx5+YN6H0gvB9y2HoeRqtLa+Ut9msA6o8KGn9uqs8C75hcWAlxfOyYsfjg0Xc3 Samson@TEEJAY"
}
