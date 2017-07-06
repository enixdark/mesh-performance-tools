variable "key_ssh" {
  description = "name of key pair in aws"
  default = "id_rsa"
} 

variable "number_instance" {
  description = "number instance server want create in aws"
  default = 1
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "aws_amis" {
  default = {
    "us-east-1" = "ami-5f709f34"
    "us-west-2" = "ami-7f675e4f"
  }
}