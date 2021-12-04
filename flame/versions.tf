terraform {
  required_providers {
    kubernetes = {
      version = "~> 2.7.0"
    }
    random = {
      version = "~> 3.0.1"
    }
    template = {
      version = "~> 2.2.0"
    }
  }
  required_version = ">= 1.0.0, < 2.0.0"
}