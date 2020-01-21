resource "aws_lambda_permission" "cw_trigger" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.monitoring.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = ""
}

resource "aws_cloudwatch_event_rule" "cw_rule" {
  name                = "AWS_Monitoring_event"
  description         = "Schedule trigger for lambda execution"
  schedule_expression = "30 15 * * ? *"
}

resource "aws_cloudwatch_event_target" "cw_target" {
  target_id = "${aws_lambda_function.monitoring}"
  rule      = "${aws_cloudwatch_event_rule.cw_rule.name}"
  arn       = "${aws_lambda_function.monitoring.function_name}"
}