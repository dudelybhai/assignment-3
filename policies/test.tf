resource "aws_s3_bucket" "valid_bucket" {
  bucket = "valid-bucket"
  tags = {
    owner       = "safi"
    environment = "dev"
  }
}

resource "aws_s3_bucket" "invalid_bucket" {
  bucket = "invalid-bucket"
  acl    = "public-read"
  tags = {
    owner = "safi"
  }
  # Missing environment tag
}

resource "aws_security_group" "invalid_sg" {
  name = "invalid-sg"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
