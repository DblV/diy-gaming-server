# diy-gaming-server
Scripts relating to DIY cloud gaming infrastructure management

You can't run Packer scripts in a different directory to your current one

You can run Terraform scripts in a different directory to your current one, hence the Terraform subfolder

You will need to provide your own password and it must match in the winrm_bootstrap.txt file and the Packer vars file - obviously, you should rotate this often.


Packer vars file should look like this:



TODO
The "aws_spot_instance_request" form of requesting a spot instance in Terraform is deprecated - needs to be updated to use the supported "market_options" style