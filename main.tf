provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Owner       = "Globomantics"
      Project     = var.project
      Environment = var.environment
    }
  }
}

resource "aws_vpc" "diamond_dogs" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = {
    name        = "${var.prefix}-vpc-${var.region}"
    environment = var.environment
  }
}

# Keep original subnet as-is (no rename)
resource "aws_subnet" "diamond_dogs" {
  vpc_id     = aws_vpc.diamond_dogs.id
  cidr_block = var.subnet_prefix  # 10.0.10.0/24 - existing, no conflict
  availability_zone = "us-east-1b"  # Add this: Supported for t2.nano

  tags = {
    name = "${var.prefix}-subnet"
  }
}

# New: Second subnet in different AZ (new CIDR to avoid conflict)
resource "aws_subnet" "diamond_dogs_secondary" {
  vpc_id            = aws_vpc.diamond_dogs.id
  cidr_block        = "10.0.20.0/24"  # New CIDR, no overlap
  availability_zone = "us-east-1a"

  tags = {
    name = "${var.prefix}-subnet-secondary"
  }
}

resource "aws_security_group" "diamond_dogs" {
  name = "${var.prefix}-security-group"

  vpc_id = aws_vpc.diamond_dogs.id

  # Updated: EC2 allows HTTP from ALB only (internal)
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-security-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# New: ALB Security Group (public HTTP/HTTPS)
resource "aws_security_group" "alb" {
  name = "${var.prefix}-alb-sg"

  vpc_id = aws_vpc.diamond_dogs.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "${var.prefix}-alb-sg"
  }
}

resource "aws_internet_gateway" "diamond_dogs" {
  vpc_id = aws_vpc.diamond_dogs.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

resource "aws_route_table" "diamond_dogs" {
  vpc_id = aws_vpc.diamond_dogs.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.diamond_dogs.id
  }
}

# Keep original association as-is
resource "aws_route_table_association" "diamond_dogs" {
  subnet_id      = aws_subnet.diamond_dogs.id
  route_table_id = aws_route_table.diamond_dogs.id
}

# New: Association for second subnet
resource "aws_route_table_association" "diamond_dogs_secondary" {
  subnet_id      = aws_subnet.diamond_dogs_secondary.id
  route_table_id = aws_route_table.diamond_dogs.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]  # Updated for latest stable (Nov 2025)
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "diamond_dogs" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.diamond_dogs.id  # Original subnet
  vpc_security_group_ids      = [aws_security_group.diamond_dogs.id]

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/files/deploy_app.sh", {
    placeholder = var.placeholder
    width       = var.width
    height      = var.height
    project     = var.project
    domain_name = var.domain_name  # Passed but unused in original script—harmless
  })

  tags = {
    Name = "${var.prefix}-diamond_dogs-instance"
  }
}

# Optional: EIP for static SSH IP (web traffic via ALB)
resource "aws_eip" "diamond_dogs" {
  instance = aws_instance.diamond_dogs.id

  tags = {
    Name = "${var.prefix}-eip"
  }
}

resource "aws_eip_association" "diamond_dogs" {
  instance_id   = aws_instance.diamond_dogs.id
  allocation_id = aws_eip.diamond_dogs.id
}

# New: ACM Certificate
resource "aws_acm_certificate" "domain_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = ["www.${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }
}

# New: ACM Validation Records (auto to Route 53)
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.domain_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.chaseloydmitchell.zone_id
}

resource "aws_acm_certificate_validation" "domain_cert_validation" {
  certificate_arn         = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# New: ALB (now with two subnets)
resource "aws_lb" "diamond_dogs" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.diamond_dogs.id, aws_subnet.diamond_dogs_secondary.id]  # Fixed: Original + new

  enable_deletion_protection = false

  tags = {
    Name = "${var.prefix}-alb"
  }
}

# New: Target Group (forwards to EC2:80)
resource "aws_lb_target_group" "diamond_dogs" {
  name     = "${var.prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.diamond_dogs.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.prefix}-tg"
  }
}

resource "aws_lb_target_group_attachment" "diamond_dogs" {
  target_group_arn = aws_lb_target_group.diamond_dogs.arn
  target_id        = aws_instance.diamond_dogs.id
  port             = 80
}

# New: ALB Listeners (HTTP → HTTPS redirect, HTTPS with ACM)
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.diamond_dogs.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.diamond_dogs.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.domain_cert_validation.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.diamond_dogs.arn
  }
}

# Data source for Route 53 hosted zone
data "aws_route53_zone" "chaseloydmitchell" {
  name         = var.domain_name
  private_zone = false
}

# Updated: Route 53 A records alias to ALB (not EIP)
resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.chaseloydmitchell.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.diamond_dogs.dns_name
    zone_id                = aws_lb.diamond_dogs.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.chaseloydmitchell.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.diamond_dogs.dns_name
    zone_id                = aws_lb.diamond_dogs.zone_id
    evaluate_target_health = true
  }
}

# Outputs
output "alb_dns_name" {
  description = "ALB DNS name for testing"
  value       = aws_lb.diamond_dogs.dns_name
}

output "certificate_arn" {
  description = "ACM Cert ARN"
  value       = aws_acm_certificate_validation.domain_cert_validation.certificate_arn
}