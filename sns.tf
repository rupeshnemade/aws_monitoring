resource "aws_sns_topic" "test" {
  name = "AWS_Monitor"
  provisioner "local-exec" {
    command = "sh sns_subscription.sh"
    environment = {
      sns_arn = self.arn
      sns_emails = "${var.sns_subscription_email_address_list}
    }
  }
}

resource "aws_sns_topic_policy" "default" {
  arn = "${aws_sns_topic.test.arn}"

  policy = "${data.aws_iam_policy_document.sns-topic-policy.json}"
}

data "aws_iam_policy_document" "sns-topic-policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect = "Allow"
    resources = [
      "${aws_sns_topic.test.arn}",
    ]

  }
}

