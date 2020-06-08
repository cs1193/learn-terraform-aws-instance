provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "terraform-getting-started-guide-example"
  acl = "private"
}

resource "aws_key_pair" "example" {
  key_name = "examplekey"
  public_key = file("~/.ssh/terraform.pub")
}


resource "aws_instance" "example" {
  key_name      = aws_key_pair.example.key_name
  ami           = "ami-0b44050b2d893d5f7" # "ami-0447a12f28fddb066"
  instance_type = "t2.micro"

  depends_on = [aws_s3_bucket.example]

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("~/.ssh/terraform")
    host = self.public_ip
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_ip} >> ip_address.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras enable nginx1.12",
      "sudo yum -y install nginx",
      "sudo systemctl start nginx"
    ]
  }
}

resource "aws_eip" "ip" {
  vpc       = true
  instance  = aws_instance.example.id
}
