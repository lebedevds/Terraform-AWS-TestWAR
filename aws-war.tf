provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "build" {
  ami = "ami-0dd9f0e7df0f0a138"
  instance_type = "t2.micro"
  subnet_id = "subnet-421eb929"
  depends_on = [aws_instance.app]
  vpc_security_group_ids = [
    aws_security_group.my-secgroup.id]
  key_name = "MyKeyPair"

connection {
  user = "ubuntu"
  private_key = "/home/ubuntu/.ssh/MyKeyPair.pem"
  agent = true
  timeout = "3m"
}

provisioner "remote-exec" {
  inline = [<<EOF
sudo apt-get update
sudo apt-get install git default-jdk maven -y
maven package
EOF
]
}


}
resource "aws_instance" "app" {
  ami = "ami-0dd9f0e7df0f0a138"
  instance_type = "t2.micro"
  subnet_id = "subnet-421eb929"
  key_name = "MyKeyPair"
  vpc_security_group_ids = [aws_security_group.my-secgroup.id]

}

resource "aws_security_group" "my-secgroup" {
  name        = "my-security-group"

ingress {
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

}
