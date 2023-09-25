# diy-gaming-server
Scripts relating to DIY cloud gaming infrastructure management


## Prerequisites
You will need: 
* An AWS account
* The AWS CLI
* Credentials for access to said AWS account using the CLI

I created the following in AWS manually, they don't get provisioned by any of the scripts:
* VPC
* Security groups
* Key pairs

You'll need to contact AWS to get them to let you have a few VCPUs

You'll need to provide a [Packer vars file|https://developer.hashicorp.com/packer/guides/hcl/variables] called _parsec-dcv-gaming-svr.pkrvars.hcl_ in the root folder - the contents should look like this:
```
winrm_username  = "gmg_user"
winrm_password   = "[YOUR PW HERE]"
winrm_port      = "5986"
```
You will need to provide your own password above and it must match the value in the winrm_bootstrap.txt file - obviously, you should rotate this often.

## Some useful things
You can't run Packer scripts in a different directory to your current one

You _can_ run Terraform scripts in a different directory to your current one, hence the Terraform subfolder (keeps files separate and neat)

## Other notes and disclaimers
The Parsec cloud preparation script is nothing to do with me, but it sets up a lot of applications, libraries and server state. It reports errors but they don't appear to be of any concern.

_scripts/setup-dcv-session.txt_ shows an example of how to kill the default dcv session and start up a new one for the gmg_user user - but I don't actually run this in the scripts at the moment.

Before you run Terraform for the first time, you'll need to cd into the Terraform folder and ```Terraform init```


### TODO
The "aws_spot_instance_request" form of requesting a spot instance in Terraform is deprecated - needs to be updated to use the supported "market_options" style