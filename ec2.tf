provider "aws" {
    region      = "ap-south-1"
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-08e0ca9924195beba"
  count=1
  key_name = "ansible"
  instance_type = "t2.micro"
  security_groups= [ "security_tom_port"]
     
  tags= {
    Name = "tomcat_instance"
  }
}


resource "aws_security_group" "security_tom_port" {
  name        = "security_tom_port"
  description = "security group for tom"
    
    ingress {
    # TLS (change to whatever ports you need)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

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

 # outbound from tomcat server
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags= {
    Name = "security_tom_port"
        
  }
    connection {
type = "ssh"
user = "ec2-user"
private_key= "ansible.pem"
host = "self.public_ip"
    }
     provisioner "file" {
    source      = "playbook.yaml"
    destination = "/tmp/playbook.yaml"
      }
 #provisioners - remote-exec 
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install  ansible2 -y",
      "sleep 10s",
      "sudo ansible-playbook -i localhost /tmp/playbook.yaml",
      "sudo chmod 657 /var/www/html"
    ]
    
  }

   provisioner "file" {
    source      = "index.html"
    destination = "/var/www/html/index.html"

 }
}

output "ec2_instance" {
    value = "${aws_instance.ec2_instance.0.public_ip}"
}
  
