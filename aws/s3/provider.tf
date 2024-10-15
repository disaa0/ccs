provider "aws" {
  region = "eu-north-1"
}

terraform {
	required_providers {
		aws = {
	    version = "~> 5.54.1"
		}
  }
}
