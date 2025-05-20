resource "aws_autoscaling_group" "grupo" {
    name = var.groupName
    vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    health_check_type         = "ELB"
    health_check_grace_period = 600
    desired_capacity = var.desired_capacity
    max_size = var.max_size
    min_size = var.min_size
    launch_template {
        id = aws_launch_template.machine_aws.id
        version = "$Latest"
    }
  target_group_arns = [ aws_lb_target_group.target_lb.arn ] 
  termination_policies = ["Default"]
}

resource "aws_autoscaling_schedule" "development-up" {
  scheduled_action_name  = "development-up"
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
  time_zone = "Europe/London"
  recurrence = "00 08 * * 1-5"
  autoscaling_group_name = aws_autoscaling_group.grupo.name
}

resource "aws_autoscaling_policy" "scaling_policy_up" {
  name                   = "scaling_policy_up"
  autoscaling_group_name = aws_autoscaling_group.grupo.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  metric_aggregation_type = "Average"
  scaling_adjustment = 2
}

resource "aws_autoscaling_policy" "scaling_policy_down" {
  name                   = "scaling_policy_down"
  autoscaling_group_name = aws_autoscaling_group.grupo.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  metric_aggregation_type = "Average"
  scaling_adjustment = -1
}

resource "aws_autoscaling_lifecycle_hook" "default" {
  name                   = "lifecycle-hook"
  autoscaling_group_name = aws_autoscaling_group.grupo.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  heartbeat_timeout      = 450 
  default_result         = "CONTINUE"
}
