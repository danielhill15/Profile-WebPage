terraform {
  required_providers {
    cloud {
      organization = "danielhill15"

      workspaces {
        name = "example-workspace"
    }
 }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.26.0"
    }
  }
}
