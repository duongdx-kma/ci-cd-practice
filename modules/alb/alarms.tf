resource "aws_cloudwatch_metric_alarm" "green_instance_failed" {
  alarm_name          = "GreenInstanceFailedAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnhealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = 1

  dimensions = {
    TargetGroup  = module.alb.target_groups["green-target-group"].arn_suffix
    LoadBalancer = module.alb.arn_suffix
  }
}

output "alb_alarm_name" {
  value = aws_cloudwatch_metric_alarm.green_instance_failed.alarm_name
}