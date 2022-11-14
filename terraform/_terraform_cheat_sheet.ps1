# standard Terraform workflow to apply a plan
terraform init                        # initializes the working directory
terraform plan -out PLAN_NAME.tfplan
terraform apply "PLAN_NAME.tfplan"

# format and validate code
terraform fmt         # format code per HCL (HashiCorp Config Language)
terraform validate    # validate syntax

# other useful commands
terraform version     # view current version
terraform refresh     # reconcile the state in the state file with the real-world resources 
terraform destroy     # tear things down to save $$
