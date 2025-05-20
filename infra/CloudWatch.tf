# resource "aws_cloudwatch_metric_alarm" "cpu_high" {
#   alarm_name          = "cpu_high"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "3"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = "30"
#   statistic           = "Average"
#   threshold           = "2"
#   alarm_description   = "This metric triggers when CPU exceeds 60%"
#   alarm_actions       = [aws_autoscaling_policy.scaling_policy_up.arn, aws_sns_topic.lambda_update_instance.arn]
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.grupo.name
#   }
#   tags = {
#     client  = "client_name"                         
#     project = "quiz"
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "cpu_low" {
#   alarm_name          = "cpu_low"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = "55"  
#   alarm_description   = "This metric triggers when CPU is below 55%"
#   alarm_actions       = [aws_autoscaling_policy.scaling_policy_down.arn]
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.grupo.name
#   }
#   tags = {
#     client  = "client_name"                         
#     project = "quiz"
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "high_response_time" {
#   alarm_name          = "high_response_time"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "3"
#   metric_name         = "TargetResponseTime"
#   namespace           = "AWS/ApplicationELB"
#   period              = "180"
#   statistic           = "Average"
#   threshold           = "5"  # Set your desired threshold
#   alarm_description   = "This metric triggers when the response time exceeds the threshold"
#   alarm_actions       = [aws_sns_topic.alarm.arn]
#   dimensions = {
#     LoadBalancer = aws_lb.alb-client_name.arn
#     TargetGroup  = aws_lb_target_group.target_lb.arn
#   }
#   tags = {
#     client  = "client_name"                         
#     project = "quiz"
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
#   alarm_name          = "status_check_failed"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "3"
#   metric_name         = "StatusCheckFailed"
#   namespace           = "AWS/EC2"
#   period              = "180"
#   statistic           = "SampleCount"
#   threshold           = "3"
#   alarm_description   = "This metric triggers when the status check fails"
#   alarm_actions       = [aws_sns_topic.alarm.arn]
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.grupo.name
#   }
#   tags = {
#     client  = "client_name"                         
#     project = "quiz"
#   }
# }



# resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
#   alarm_name          = "unhealthy_hosts"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "UnHealthyHostCount"
#   namespace           = "AWS/ApplicationELB"
#   period              = "60"
#   statistic           = "SampleCount"
#   threshold           = "2"  # Set your desired threshold
#   alarm_description   = "This metric triggers when the number of unhealthy hosts exceeds the threshold"
#   alarm_actions       = [aws_sns_topic.alarm.arn]
#   dimensions = {
#     LoadBalancer = aws_lb.alb-client_name.arn
#     TargetGroup  = aws_lb_target_group.target_lb.arn
#   }
#   tags = {
#     client  = "client_name"                         
#     project = "quiz"
#   }
# }