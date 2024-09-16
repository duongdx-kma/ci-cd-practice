resource "aws_iam_role" "codedeploy_service_role" {
  name = "codedeploy_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        },
      },
    ],
  })
}

# codedeploy policy
resource "aws_iam_policy" "codedeploy_access_policy" {
  name = "codedeploy_access_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "autoscaling:CompleteLifecycleAction",
          "autoscaling:DeleteLifecycleHook",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLifecycleHooks",
          "autoscaling:PutLifecycleHook",
          "autoscaling:RecordLifecycleActionHeartbeat",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DetachInstances",
          "ec2:AttachInstances",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DescribeInstanceHealth",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ],
  })
}

# codedeploy policy
resource "aws_iam_role_policy_attachment" "codedeploy_access_policy_attachment" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = aws_iam_policy.codedeploy_access_policy.arn
}
