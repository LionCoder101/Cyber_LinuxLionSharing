# Using AWS with Terraform

## Prerequisites
Before using Terraform with AWS, make sure you have:
- Terraform installed
- An AWS account
- AWS CLI installed and configured
- Appropriate IAM permissions

## Configure AWS Credentials
Run the AWS CLI configure command:
```bash
aws configure
```

Provide:
- AWS Access Key ID
- AWS Secret Access Key
- Default region
- Output format

## Simple Example: Create an S3 Bucket
Create a folder called `aws-example` and add this file named `main.tf`:
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
  bucket = "my-terraform-example-bucket-12345"
  tags = {
    Name        = "TerraformExample"
    Environment = "Dev"
  }
}
```

## Commands
```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

## Important Notes
- Use unique bucket names globally
- Never hardcode secrets in Terraform files
- Use IAM least privilege access
- Review the plan output before applying

## Best Practices
- Keep resources small for learning
- Destroy test resources when done
- Store state securely
- Use variables for values that change often
