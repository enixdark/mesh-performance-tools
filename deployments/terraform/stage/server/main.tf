provider "aws" {
  # access_key = ""
  # secret_key = ""
  region     = "us-east-1"
}

resource "aws_security_group" "default" {
  name        = "security_cli"
  description = "Used in the terraform"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "cli" {
  # name          = "server"

  count         = "${var.number_instance}"
  ami      = "ami-40d28157"
  instance_type = "${var.instance_type}"

  # Security group
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  user_data       = "${file("userdata.sh")}"
  key_name        = "${var.key_ssh}"

  # Copy file to remote server
  provisioner "file" {
    source      = "ansible"
    destination = "/home/ubuntu"
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa.key")}"
      agent = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  provisioner "file" {
    source      = "userdata.sh"
    destination = "/tmp/script.sh"
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa.key")}"
      agent = true
    }
  }

  # install all packages for ansible
  provisioner "remote-exec" {
    inline = [
      # "chmod +x /tmp/script.sh",
      # "/tmp/script.sh"
      # "sudo apt-get update qq -y",
      # "sudo apt-get install python3-dev libffi-dev libssl-dev -y -qq",
      # "wget --quiet 'https://bootstrap.pypa.io/get-pip.py'",
      # "sudo python3 get-pip.py",
      # "sudo pip install ansible"
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt-get update -y",
      "sudo apt-get install ansible -y -qq"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa.key")}"
      agent = true
    }
  }
}


# resource "null_resource" "install" {

#   triggers {
#     key = "${uuid()}"
#   }

#   provisioner "local-exec" {
#     command = "sudo apt-get install python-pip"
#   }
# }