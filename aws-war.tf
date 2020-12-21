provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "build" {
  ami = "ami-0dd9f0e7df0f0a138"
  instance_type = "t2.micro"
  tags = {
    Name = "build"
  }
  subnet_id = "subnet-421eb929"
  depends_on = [aws_instance.app]
  vpc_security_group_ids = [
    aws_security_group.my-secgroup.id]
  key_name = "MyKeyPair"
  user_data = file("./key.sh")

connection {
  type = "ssh"
  user = "ubuntu"
  private_key = file("/home/ubuntu/.ssh/MyKeyPair.pem")
  agent = false
  timeout = "3m"
  host = aws_instance.build.public_ip
}

provisioner "remote-exec" {
  inline = [<<EOF
sudo apt update
sudo apt install git default-jdk -y
sudo apt install maven -y
sudo apt install awscli -y
cd /tmp/ && git clone https://github.com/lebedevds/test-webapp.git && mvn package -f /tmp/test-webapp/pom.xml
aws s3 cp /tmp/test-webapp/target/hello-1.0.war s3://mybacket1.test5.com/
EOF
]
}


}
resource "aws_instance" "app" {
  ami = "ami-0dd9f0e7df0f0a138"
  instance_type = "t2.micro"
  tags = {
    Name ="app"
  }
  subnet_id = "subnet-421eb929"
  key_name = "MyKeyPair"
  vpc_security_group_ids = [aws_security_group.my-secgroup.id]
  connection {
  type = "ssh"
  user = "ubuntu"
  private_key = file("/home/ubuntu/.ssh/MyKeyPair.pem")
  agent = false
  timeout = "3m"
  host = aws_instance.app.public_ip
}

provisioner "remote-exec" {
  inline = [<<EOF
sudo apt update
sudo apt install tomcat9 -y
EOF
]
}

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
