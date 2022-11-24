# standard Terraform workflow to apply a plan
terraform init                        # initializes the working directory
terraform plan -out PLAN_NAME.tfplan
terraform apply "PLAN_NAME.tfplan"

# format and validate code
terraform fmt         # format code per HCL (HashiCorp Config Language)
terraform validate    # validate syntax

# environments
terraform workspace list            # view configured envs
terraform workspace new Dev         # create a new workspace called 'Dev'
terraform workspace select default  # switch to the 'default' workspace

# other useful commands
terraform version     # view current version
terraform refresh     # reconcile the state in the state file with the real-world resources 
terraform destroy     # tear things down to save $$
terraform console     # launches the console, allowing you to test commands

# functions - https://developer.hashicorp.com/terraform/language/functions
upper("taco")
lower("TACO")
min(42,5,16)
max(5, 12, 9)
range(100,500)    # produce numbers between the range given

# get the value of a single element from a map given its key
# lookup(map, key, default)
lookup({a="ay", b="bee"}, "a", "unknown")
#ay
lookup({a="ay", b="bee"}, "c", "unknown")
# unknown

# calculate a full host ip address for a given host number within a given prefix
# cidrhost(prefix, hostnum)
cidrhost("10.12.112.0/20", 16)
# 10.12.112.16
cidrhost("10.12.112.0/20", 268)
# 10.12.113.12
cidrhost("fd00:fd12:3456:7890:00a2::/72", 34)
# fd00:fd12:3456:7890::22

# calculate a subnet address within given IP network address prefix
# cidrsubnet(prefix, newbits, netnum)
cidrsubnet("172.16.0.0/12", 4, 2)
# 172.18.0.0/16
cidrsubnet("10.1.2.0/24", 4, 15)
# 10.1.2.240/28
cidrsubnet("fd00:fd12:3456:7890::/56", 16, 162)
# fd00:fd12:3456:7800:a200::/72

