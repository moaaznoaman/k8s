resource "aws_security_group" "allow-connection" {
  vpc_id      = aws_vpc.main.id
  name        = "allow-connection"
  description = "security group that allows all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
//  ingress {
//    from_port   = 22
//    to_port     = 22
//    protocol    = "TCP"
//    cidr_blocks = [aws_subnet.main-public-1.cidr_block]
//  }

//  ingress {
//    from_port   = 0
//    to_port     = 65535
//    protocol    = "tcp"
////    cidr_blocks = [aws_subnet.main-public-1.cidr_block]
//    cidr_blocks = ["0.0.0.0/0"]
//
//  }
    dynamic "ingress" {
      for_each = var.protocals
      content {
        from_port   = 0
        to_port     = 65535
        cidr_blocks = ["0.0.0.0/0"]
        protocol    = ingress.value
      }
    }

  tags = {
    Name = "allow-connections"
  }
}


//resource "aws_security_group" "allow-connection" {
//  name        = "allow connections"
//  vpc_id      = aws_vpc.main.id
//  description = "security group that allows all egress traffic"
//
//  egress {
//    from_port   = 0
//    to_port     = 0
//    protocol    = "-1"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//
//  dynamic "ingress" {
//    for_each = var.ports
//    content {
//      from_port   = ingress.key
//      to_port     = ingress.key
//      cidr_blocks = ingress.value
//      protocol    = "tcp"
//    }
//  }
//}
