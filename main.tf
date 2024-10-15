terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.54.1"
    }
  }
  backend "s3" {
    bucket = "tul-ccs-terraform"
    key    = "terraform.tfstate"
    region = "eu-north-1"
  }
}


module "s3" {
  source = "./aws/s3"
}
module "cognito" {
  source = "./aws/cognito"
}
module "dynamodb" {
  source = "./aws/dynamodb"
}
# module "lambda" {
#   source = "./aws/lambda"
# }
