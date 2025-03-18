region  = "us-east-2"
key     = "terraform.tfstate"
profile = "controlplane"

bucket         = "use2-iac-controlplane-tf-states"
dynamodb_table = "use2-iac-controlplane-tf-state-lock"
