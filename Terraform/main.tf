terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-1"
}

variable "ami_id" {
  type    = string
  default = null
}

variable "instance_type" {
  type    = string
  default = "g4dn.xlarge"
}

variable "instance_size" {
  type    = string
  default = "60"
}

data "aws_instance" "gaming_server" {
  filter {
    name   = "spot-instance-request-id"
    values = [aws_spot_instance_request.gaming_server_request.id]
  }
}

resource "aws_spot_instance_request" "gaming_server_request" {
  ami                    = "${var.ami_id}"
  spot_type              = "one-time"
  instance_type          = "${var.instance_type}"
  key_name               = "ParsecSvrKeyPair2"
  vpc_security_group_ids = ["sg-0796717afb762bea2","sg-087c30af488f57135"]
  wait_for_fulfillment   = true
  root_block_device {
    volume_size = var.instance_size
  }
}
