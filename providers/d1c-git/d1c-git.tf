variable "name"              { }
variable "environment"          { }
variable "application"          { }
variable "terraform_template"     { default =   "d1c-git" }
variable "region"              { }
variable "role_arn"              { }

terraform {
  backend "s3" {
    bucket = "cfn-buildscripts"
    region = "us-east-1"
    key = "d1c-git/terraform.tfstate"
    profile = "default"
  }
}

atlas {
  name = "fams/git-d1c-poc"
}

provider "aws" {
  region = "${var.region}"
  assume_role {
    role_arn = "${var.role_arn}"
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid = "1"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*",
    ]
  }
}

module "lambda_iam_role" {
   source       = "../../modules/util/iam"

   name         = "${var.environment}-${var.name}-LambdaServiceRole"
   create_group = "false"
   role         = "lambda.amazonaws.com"
   policy       = "${data.aws_iam_policy_document.lambda_policy.json}"
   is_inline    = "true"

}

data "aws_iam_policy_document" "nginx_policy" {
  statement {
    sid = "1"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
  statement {
    sid = "2"

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::itxcdn",
      "arn:aws:s3:::itxcdn/*",
      "arn:aws:s3:::famsdna-codedeploy",
      "arn:aws:s3:::famsdna-codedeploy/*",
      "arn:aws:s3:::famsdna-codedeploy-us-east-2",
      "arn:aws:s3:::famsdna-codedeploy-us-east-2/*"
    ]
  }
  statement {
    sid = "3"

    actions = [
      "ec2:DescribeTags"
    ]

    resources = [
      "*"
    ]
  }
  statement {
    sid = "4"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [
      "arn:aws:lambda:us-east-1:837299327104:function:echoEvent"
    ]
  }
}

module "nginx_iam_role" {
   source       = "../../modules/util/iam"

   name         = "${var.environment}-${var.name}-NginxEc2Role"
   create_group = "false"
   role         = "ec2.amazonaws.com"
   policy       = "${data.aws_iam_policy_document.nginx_policy.json}"
   is_inline    = "true"

}


output "lambda_role_name" { value = "${module.lambda_iam_role.role_name}" }
output "lambda_role_arn" { value = "${module.lambda_iam_role.role_arn}" }
output "nginx_role_name" { value = "${module.nginx_iam_role.role_name}" }
output "nginx_instance_profile_arn" { value = "${module.nginx_iam_role.instance_profile_arn}" }