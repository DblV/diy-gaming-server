# diy-gaming-server
Scripts relating to DIY cloud gaming infrastructure management

You can't run Packer scripts in a different directory to your current one

You can run Terraform scripts in a different directory to your current one, hence the Terraform subfolder

You will need to provide your own password and it must match in the winrm_bootstrap.txt file and the Packer vars file - obviously, you should rotate this often.


Prerequisites

AWS account
AWS CLi
AWS credentials
AWS VPC
Security groups
Key pairs

You'll need to contact AWS to get them to let you have a few VCPUs

Packer vars file parsec-dcv-gaming-svr.pkrvars.hcl should look like this:
```
winrm_username  = "gmg_user"
inrm_password   = "[YOUR PW HERE]"
winrm_port      = "5986"
```

Other notes
The Parsec cloud preparation script is nothing to do with me, but it sets up a lot of applications, libraries and server state. It reports errors but they don't appear to be of any concern.

setup-dcv-session shows an example of how to kill the default dcv session and start up a new one for the gmg_user user

TODO
The "aws_spot_instance_request" form of requesting a spot instance in Terraform is deprecated - needs to be updated to use the supported "market_options" style