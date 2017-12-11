provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "ansible-demo" {
  cidr_block            = "10.10.0.0/16"
  enable_dns_hostnames  = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.ansible-demo.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.ansible-demo.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.ansible-demo.id}"
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "ansible-demo-sg" {
  name = "ansible_demo_sg"
  description = "SG for SSH/HTTP access"
  vpc_id = "${aws_vpc.ansible-demo.id}"

  # SSH 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP 
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  # Outbound Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ansible-node" {
  #name          = "${var.instance_name}"
  ami            = "${var.ami}"
  instance_type  = "${var.size}"
  key_name       = "${var.key}"
  count          = "${var.count}"
  
  
  vpc_security_group_ids = ["${aws_security_group.ansible-demo-sg.id}"]
  subnet_id = "${aws_subnet.default.id}"

  tags {
    environment = "non-production"
    Name        = "ansible-demo-${count.index}"
  }

#  provisioner "local-exec" {
#    command = "echo ${aws_instance.ansible-node.public_dns} >> terraform_hosts"
#  }
}

output "public_ip" {
  value = ["${aws_instance.ansible-node.*.public_ip}"]
}

output "public_dns" {
  value = ["${aws_instance.ansible-node.*.public_dns}"]
}
