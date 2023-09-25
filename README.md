# diy-gaming-server
Scripts relating to DIY cloud gaming infrastructure management

These scripts break down into 2 categories - bake and fry. The bake scripts are for getting a server image provisioned in AWS for later use, and the fry scripts are for actually spinning up a server for live use.

You can use _run.ps1_ to provide useful information about your current EC2 state in AWS and to run the Packer and Terraform commands for you.

### Bake (Packer)
_parsec-dcv-gaming-svr.pkr.hcl_ is a [Packer|https://developer.hashicorp.com/packer] configuration as code file; it will try to find the latest version of a [NICE DCV|https://aws.amazon.com/hpc/dcv/] AMI from the marketplace and use that as the base for the server image. This means the DCV agent and the NVidia drives are already on the image, and the script just needs to set up the [Parsec|https://parsec.app] agent and add a few other useful things, and then the AMI is sysprepped and ready to be a gaming host for either DCV or Parsec connections.

### Fry (Terraform)
_Terraform/main.tf_ is a [Terraform |https://developer.hashicorp.com/terraform] configuration as code file; it will spin up a spot instance of an AMI with the provisioning requirements you provide (instance type, storage).

Before you run Terraform for the first time, you'll need to cd into the Terraform folder and ```Terraform init```

## Prerequisites
You will need:
* An AWS account
* The [AWS CLI|https://aws.amazon.com/cli/]
* Credentials for access to said AWS account using the CLI
* [Packer application|https://developer.hashicorp.com/packer/downloads]
* [Terraform application|https://developer.hashicorp.com/terraform/downloads]

I created the following in AWS manually, they don't get provisioned by any of the scripts:
* VPC
* Security groups (these will need custom TCP and UDP rules, see the DCV/Parsec docs for details there rather than trusting me :D )
* Key pairs

You'll need to contact AWS support and raise a case with them to let you have a few VCPUs in your region of choice (well I had to anyway)

You'll need to provide a [Packer vars file|https://developer.hashicorp.com/packer/guides/hcl/variables] called _parsec-dcv-gaming-svr.pkrvars.hcl_ in the root folder - the contents should look like this:
```
winrm_username  = "gmg_user"
winrm_password   = "[YOUR PW HERE]"
winrm_port      = "5986"
```
You will need to provide your own password above and it must match the value in the _scripts/winrm_bootstrap.txt_ file - obviously, you should rotate this often.

## Some useful things I found out
You can't run Packer scripts in a different directory to your current one

You _can_ run Terraform scripts in a different directory to your current one, hence the Terraform subfolder (keeps files separate and neat)

## Other notes and disclaimers
The Parsec cloud preparation script that is called from _scripts/install_parsec.ps1_ is nothing to do with me, but it sets up a lot of applications, libraries and server state. It reports errors but they don't appear to be of any concern. See the Parsec cloud preparation script code on Github [here|https://github.com/parsec-cloud/Parsec-Cloud-Preparation-Tool]

_scripts/setup-dcv-session.txt_ shows an example of how to kill the default dcv session and start up a new one for the gmg_user user - but I don't actually run this in the scripts at the moment. It's useful to run manually though if you are looking to use DCV and you want to run it with the gmg_user account and not the default Administrator Windows account.

### TODO
The "aws_spot_instance_request" form of requesting a spot instance in Terraform is deprecated - needs to be updated to use the supported "market_options" style