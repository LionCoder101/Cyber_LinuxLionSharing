# Terraform Lesson 1: Beginner Study Guide

## What is Terraform?
Terraform is an Infrastructure as Code (IaC) tool that lets you define cloud resources in configuration files.

It helps you:
- Create infrastructure consistently
- Reuse configuration across environments
- Track changes with version control
- Automate deployment

## Main Concepts
- Provider: A service plugin such as AWS, Azure, or Google Cloud
- Resource: A real infrastructure object such as an EC2 instance or S3 bucket
- Variable: A configurable input value
- Output: A value shown after Terraform runs
- State: Terraform stores the current infrastructure state in a file

## Basic Terraform Workflow
1. Write configuration files
2. Run `terraform init`
3. Run `terraform plan`
4. Run `terraform apply`
5. Run `terraform destroy` when finished

## Example Configuration
```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket-12345"
}
```

## Important Commands
- `terraform init` - initialize the working directory
- `terraform validate` - check syntax
- `terraform plan` - preview changes
- `terraform apply` - create or update resources
- `terraform destroy` - remove resources

## Study Tips
- Practice one small example at a time
- Read the plan output carefully
- Learn one provider before moving to another
- Keep your configuration simple and readable
