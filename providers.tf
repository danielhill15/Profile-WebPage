terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.26.0"
    }
  }
  cloud {
      organization = "danielhill15"

      workspaces {
        name = "example-workspace"
    }
 }
}
