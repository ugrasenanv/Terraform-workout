resource "aws_cloudwatch_dashboard" "cpu_utilization" {
  dashboard_name = "CPUUtilizationDashboard"
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${aws_autoscaling_group.grupo.name}" ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-west-2",
        "title": "CPU Utilization"
      }
    }
  ]
}
EOF
}

resource "aws_cloudwatch_dashboard" "response_time" {
  dashboard_name = "ResponseTimeDashboard"
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${aws_lb.alb-client_name.arn}", "TargetGroup", "${aws_lb_target_group.target_lb.arn}" ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-west-2",
        "title": "Response Time"
      }
    }
  ]
}
EOF
}

resource "aws_cloudwatch_dashboard" "status_check" {
  dashboard_name = "StatusCheckDashboard"
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/EC2", "StatusCheckFailed", "AutoScalingGroupName", "${aws_autoscaling_group.grupo.name}" ]
        ],
        "period": 300,
        "stat": "SampleCount",
        "region": "eu-west-2",
        "title": "Status Check Failed"
      }
    }
  ]
}
EOF
}

resource "aws_cloudwatch_dashboard" "unhealthy_hosts" {
  dashboard_name = "UnhealthyHostsDashboard"
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/ApplicationELB", "UnHealthyHostCount", "LoadBalancer", "${aws_lb.alb-client_name.arn}", "TargetGroup", "${aws_lb_target_group.target_lb.arn}" ]
        ],
        "period": 300,
        "stat": "SampleCount",
        "region": "eu-west-2",
        "title": "Unhealthy Hosts"
      }
    }
  ]
}
EOF
}