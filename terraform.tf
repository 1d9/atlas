terraform {
  backend "remote" {
    organization = "1d9"

    workspaces {
      name = "atlas"
    }
  }
}

provider "aws" {
  profile    = "default"
  region     = "ap-southeast-2"
}