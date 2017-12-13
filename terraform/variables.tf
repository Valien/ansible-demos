#variable "access_key" {}
#variable "secret_key" {}

variable "region" {
    description = "AWS region to launch server"
    default     = "us-east-2"
}
variable "instance_name" {
    default = "f8f-demo-ansible-av"
}
# this AMI is on us-east-2 and is an Amazon Linux AMI
variable "ami" {
    default = "ami-c5062ba0"
}
variable "size" {
    default = "t2.micro"
}

variable "count" {
    default = 6
}

variable "key" {}