# Terraform Exam Dump

## Quick Review Questions

### 1. What is Terraform?
Terraform is an Infrastructure as Code tool used to define and manage infrastructure using configuration files.

### 2. What is HCL?
HCL stands for HashiCorp Configuration Language. It is the language used to write Terraform configuration.

### 3. What does `terraform init` do?
It initializes a Terraform working directory and downloads required providers and modules.

### 4. What does `terraform plan` do?
It shows what Terraform will create, change, or destroy before applying changes.

### 5. What does `terraform apply` do?
It applies the planned changes to create or update resources.

### 6. What does `terraform destroy` do?
It removes the resources managed by Terraform.

### 7. What is a provider?
A provider is a plugin that allows Terraform to interact with a specific platform like AWS, Azure, or GCP.

### 8. What is a resource?
A resource is a real infrastructure object managed by Terraform, such as an S3 bucket or EC2 instance.

### 9. What is Terraform state?
Terraform state tracks the current state of resources managed by Terraform.

### 10. Why is state important?
State helps Terraform know what already exists so it can update resources safely.

## Common Exam Commands
```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Important Concepts to Remember
- Use `terraform plan` before `terraform apply`
- State files should be handled carefully
- Variables make configuration reusable
- Outputs provide useful values after apply
- Providers are required for each platform

## Sample Practice Scenario
Create an S3 bucket using Terraform and AWS.

### Example
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket-12345"
}
```

## Exam Tips
- Understand the Terraform lifecycle
- Know the difference between plan and apply
- Practice with simple AWS resources
- Review provider and resource basics
- Learn common commands and their purpose
