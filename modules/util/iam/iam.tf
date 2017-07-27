#--------------------------------------------------------------
# This module is used to create an AWS IAM group and its users
#--------------------------------------------------------------

variable "name" {
  default = "iam"
}

variable "policy" {}

variable "role" {
  default = "none"
}

variable "create_group" {
  default = "true"
}

variable "is_inline" {
  default = "false"
}

resource "aws_iam_policy" "policy" {
  name   = "${var.name}"
  policy = "${var.policy}"
  count  = "${var.is_inline == "true" ? 0 : 1}"
}

resource "aws_iam_group" "group" {
  name  = "${var.name}"
  count = "${var.create_group == "true" ? 1 : 0}"
}

resource "aws_iam_group_policy_attachment" "group-attach" {
  group      = "${aws_iam_group.group.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
  count      = "${var.create_group == "true" ? 1 : 0}"
}

resource "aws_iam_role" "role" {
  name  = "${var.name}"
  count = "${var.role == "none" ? 0 : 1}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ${jsonencode(split(",", var.role))}
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile" {
  name  = "${var.name}"
  role = "${aws_iam_role.role.name}"
  count = "${lookup(zipmap(split(",", var.role),split(",", var.role)), "ec2.amazonaws.com", "NotFound" ) == "ec2.amazonaws.com" ? 1 : 0}"
}

resource "aws_iam_role_policy_attachment" "role-attach" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
  count      = "${(var.role != "none")  && (var.is_inline == "false") ? 1 : 0}"
}

resource "aws_iam_role_policy" "role_inline_policy" {
  name   = "${var.name}-inline-policy"
  role   = "${aws_iam_role.role.id}"
  policy = "${var.policy}"
  count  = "${var.is_inline == "true" ? 1 : 0}"
}

output "role_arn" {
  value = "${aws_iam_role.role.arn}"
}

output "role_name" {
  value = "${aws_iam_role.role.name}"
}

output "group_name" {
  value = "${aws_iam_group.group.name}"
}

output "instance_profile_arn" {
  value = "${aws_iam_instance_profile.instance_profile.arn}"
}

