provider "aws" {
  region = "us-east-1"
}

# Generate SSH key locally
resource "tls_private_key" "jenkins" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key locally
resource "local_file" "private_key" {
  content              = tls_private_key.jenkins.private_key_pem
  filename             = "${path.module}/jenkins.pem"
  file_permission      = "0400"
  directory_permission = "0700"
}

# Upload public key to AWS
resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key-new"
  public_key = tls_private_key.jenkins.public_key_openssh
}

# Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-new-sg"
  description = "Allow SSH, Jenkins, HTTP, HTTPS"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
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
    Name = "jenkins-sg"
  }
}

# EC2 Instance
resource "aws_instance" "jenkins" {
  ami                    = "ami-0bdd88bd06d16ba03" # Amazon Linux 2023
  instance_type          = "c7i-flex.large"
  key_name               = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  root_block_device {
    volume_size           = 40
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "Jenkins"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.jenkins.private_key_pem
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [

      # Wait for cloud-init
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 5; done",

      # System update
      "sudo dnf update -y",

      # Install packages
      "sudo dnf install -y git docker maven tree wget java-21-amazon-corretto-devel",

      # Enable Docker
      "sudo systemctl enable docker",
      "sudo systemctl start docker",

      # Docker permissions
      "sudo usermod -aG docker ec2-user",

      # Add Jenkins repo
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",

      # Import Jenkins key
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",

      # Install Jenkins
      "sudo dnf install -y jenkins",

      # Add Jenkins to Docker group
      "sudo usermod -aG docker jenkins",

      # Enable Jenkins
      "sudo systemctl daemon-reload",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",

      # Wait for Jenkins password
      "echo 'Waiting for Jenkins to initialize...'",
      "for i in $(seq 1 30); do if sudo test -f /var/lib/jenkins/secrets/initialAdminPassword; then break; fi; echo Waiting... $i; sleep 10; done",

      # Print password
      "echo 'Jenkins Initial Admin Password:'",
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    ]
  }
}
