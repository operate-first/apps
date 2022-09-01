# Terraform configuration for AWS

Credentials to AWS can be found in shared Bitwarden vault for Operate First as a secure note **AWS Credentials**.

Usage:

```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

terraform init
terraform apply
```

Lint and validate changes:

```bash
terraform fmt
terraform validate
```

## MultiClusterObservability

Configuration ensures presence of:

- IAM user **operate-first-multi-cluster-observability** with API credentials
- Policy **operate-first-multi-cluster-observability-bucket-rw** granting the user above RW access to bucket mentioned below
- S3 Bucket **operate-first-multi-cluster-observability-thanos**

Configuration outputs:

- `bucket`
- `access_key` (sensitive)
- `secret_key` (sensitive)

> Note: To view sensitive outputs, use `terraform output <variable>`.
