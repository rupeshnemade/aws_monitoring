
variable "region" {
  description = "Region that the instances will be created"
}

variable "sns_subscription_email_address_list" {
  type = string
  description = "List of email addresses as string(space separated)"
}

variable "environment" {
  description = "deployment environment"
}
