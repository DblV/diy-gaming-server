packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.5"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
    type = string
    default = "parsec-gmg-svr"
}

variable "winrm_port" {
  type    = string
  default = null
}

variable "winrm_username" {
  type    = string
  default = null
}

variable "winrm_password" {
  type    = string
  default = null
}

locals {
    timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

# Use the following AWS CLI command to search for relevant marketplace AMIs
#aws ec2 describe-images --region eu-west-1 --filters "Name=platform,Values=windows" "Name=name,Values=*DCV-Windows-2023*NVIDIA-gaming*"
data "amazon-ami" "gmg-svr" {
  filters = {
      name                = "*DCV-Windows-2023*NVIDIA-gaming*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
  }
  region      = "eu-west-1"
  most_recent = true
  owners      = ["877902723034"]
}

source "amazon-ebs" "gmg-svr" {
  ami_block_device_mappings {
      device_name = "/dev/sda1"
      delete_on_termination = true
      volume_size = 30
      volume_type = "gp2"
  }  
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "g4dn.xlarge"
  region        = "eu-west-1"
  source_ami    = data.amazon-ami.gmg-svr.id
  force_deregister = "true"
  user_data_file = "./shared-scripts/winrm-bootstrap.txt"
  communicator = "winrm"
  winrm_insecure = "true"
  winrm_port = "${var.winrm_port}"
  winrm_username= "${var.winrm_username}"
  winrm_password = "${var.winrm_password}"
  winrm_use_ntlm = "true"
  winrm_use_ssl = "true"
  winrm_timeout = "15m"
  launch_block_device_mappings {
      device_name = "/dev/sda1"
      delete_on_termination = true
      volume_size = 30
      volume_type = "gp2"
  }  
}

build {
  name = "packer-build-gmg-svr"
  sources = [ "source.amazon-ebs.gmg-svr" ]

  provisioner "powershell" {
    elevated_password = "${var.winrm_password}"
    elevated_user = "${var.winrm_username}"
    script = "./scripts/install-choco.ps1"
  }

  provisioner "powershell" {
    elevated_password = "${var.winrm_password}"
    elevated_user = "${var.winrm_username}"
    inline = [
      "choco install microsoft-edge -y",
      "choco install epicgameslauncher -y",
      "choco install steam -y",
      "choco install goggalaxy -y",
      ]
  }

  provisioner "powershell" {
    elevated_password = "${var.winrm_password}"
    elevated_user = "${var.winrm_username}"
    script = "./scripts/install-parsec.ps1"
  }

  provisioner "powershell" {
    elevated_password = "${var.winrm_password}"
    elevated_user = "${var.winrm_username}"
    inline = [
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule", 
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SysprepInstance.ps1 -NoShutdown"
      ]
  }
}
