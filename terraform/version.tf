# configura a versão dos providers que devem ser usados
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.65.0"
    }
  }
}

# configura a zona e profile do provider aws
provider "aws" {
  region = "sa-east-1"
  profile = "terraform_user"
}