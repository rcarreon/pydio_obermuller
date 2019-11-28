provider "aws" {
 region = "us-west-1"
 version = "~> 2.5.0"
 #access_key = "${var.aws_access_key}"
 #secret_key = "${var.aws_secret_key}"
}
## Backend ##
#terraform {
#        backend "s3" {
#        bucket="obermuller-iac-terraform-state"
#        key="wrkshop/"
#        region="us-west-1"
#        }
#}

