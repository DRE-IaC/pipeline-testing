## Why is "profile" designated in two places?

The variable "profile" is both in backend.tfvars and vars file, this is because backend.tfvars is used during `terraform init` only
all other terraform commands will use the vars file. This is just how variables work because `init` is a special situation
with terraform. The value of profile must be identical in both files.