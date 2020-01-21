# IAM role which dictates what other AWS services the Lambda function
# may access.

//lambda role
data "aws_iam_policy_document" "AWSMonitorLambda_role_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AWSMonitorLambda_role" {
  name = "AWS_Monitor_LambdaRole"

  assume_role_policy = "${data.aws_iam_policy_document.AWSMonitorLambda_role_document.json}"
}

data "aws_iam_policy_document" "AWSMonitorLambda_document" {

  statement {
    actions = [
      "sns:Publish",
      "sns:Subscribe"
    ]

    resources = [
      "${aws_sns_topic.test.arn}",
    ]

    effect = "Allow"
    sid = "SNSPermissions"
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]

    effect = "Allow"
    sid = "AllowWriteToCloudwatchLogs"
  }

  statement {
    effect = "Allow"
    sid = "AWSServices"
    resources = ["*"]
    actions = [
      "sagemaker:ListTags",
      "sagemaker:DescribeNotebookInstance",
      "sagemaker:ListNotebookInstances",
      "sagemaker:ListEndpoints",
      "sagemaker:StopNotebookInstance",
      "glue:GetDevEndpoints",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeVolumes",
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]
  }
}

resource "aws_iam_role_policy" "AWSMonitorLambda_policy" {
  name = "AwSamReportPublishLambdaPolicy"
  role = "${aws_iam_role.AWSMonitorLambda_role.id}"

  policy = "${data.aws_iam_policy_document.AWSMonitorLambda_document.json}"
}

