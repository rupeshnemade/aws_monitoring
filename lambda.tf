provider "aws" {
  region          = "${var.region}"
}

data "archive_file" "lambda_zip" {
  type          = "zip"
  source_file   = "lambda_function.py"
  output_path   = "lambda_function.zip"
}

resource "aws_lambda_function" "monitoring" {

  function_name    = "AWS_Service_Monitoring"
  filename         = "lambda_function.zip"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  handler          = "lambda_handler.handler"
  runtime          = "python2.7"
  timeout          = "${var.lambda_timeout}"
  
  role             = "${aws_iam_role.AWSMonitorLambda_role.arn}"
  
  tags = "${local.tags}"

  depends_on = ["aws_iam_role.AWSMonitorLambda_role"]


}

