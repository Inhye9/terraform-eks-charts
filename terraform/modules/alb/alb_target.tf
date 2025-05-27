# Target Group 생성
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.instance_name}-alb-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags,{
    Name = "${var.instance_name}-alb-tg"
  })
}

# Listener 생성
resource "aws_lb_listener" "target_group-alb-listener" {
  #load_balancer_arn = aws_lb.public_lb.arn
  load_balancer_arn = var.load_balancer_arn
  port              = var.alb_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

  tags = merge(local.common_tags,{
    Name = "${var.instance_name}-alb-listener"
  })
}


# Target Group Attachment
resource "aws_lb_target_group_attachment" "target_group_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.ec2.id
  port             = var.alb_listener_instance_port
}