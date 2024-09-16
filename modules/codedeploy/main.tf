# Create a CodeDeploy Application
resource "aws_codedeploy_app" "app" {
  name             = "my-codedeploy-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "dg" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = "blue-green-dg"
  service_role_arn       = aws_iam_role.codedeploy_service_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 60
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb_https_listener_arn]
      }

      test_traffic_route {
        listener_arns = [var.alb_https_listener_arn]
      }

      target_group {
        name = var.alb_blue_target_name
      }

      target_group {
        name = var.alb_green_target_name
      }
    }
  }

  alarm_configuration {
    enabled = true
    alarms  = [var.alb_alarm_name]
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM", "DEPLOYMENT_STOP_ON_REQUEST"]
  }
}