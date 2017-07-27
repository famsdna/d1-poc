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

resource "aws_vpc_dhcp_options" "foo" {
  domain_name          = "service.consul"
  domain_name_servers  = ["127.0.0.1", "10.0.0.3"]
  ntp_servers          = ["127.0.0.1"]
  netbios_name_servers = ["127.0.0.1"]
  netbios_node_type    = 2

  tags {
    Name = "${var.name}"
    Application = "${var.application}"
    Environment = "${var.environment}"
  }
}