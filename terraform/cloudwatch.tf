resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc-flow-logs"
  retention_in_days = 30
}
