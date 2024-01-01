terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# resource "aws_vpc" "example" {
#   cidr_block = "10.0.0.0/16"
# }

variable "strategy" {
  description = "strategy name"
  type = string

  default = "SampleStrategy"
}

variable "env" {
  description = "environment variable"
  type = string

  validation {
    condition     = length(regexall("^(local|dev|prod)$", var.env)) > 0
    error_message = "ERROR: Valid types are \"local\", \"dev\" and \"prod\"!"
  }

  default = "local"
}
variable "aws_var" {
  description = "AWS credentails and EC2 instance"
  type = object({
    private_key: string,
    access_key: string,
    secret_key: string,
    ec2: object({
      user: string,
      ami: string,
      instance_type: string,
      subnet_id: string,
      security_group_ids: list(string),
      key_name: string,
      ip_v4: string
    })
  })
  default = {
    private_key = "value"
    access_key = "value"
    ec2 = {
      user = "ubuntu"
      ami = "value"
      instance_type = "value"
      key_name = "value"
      security_group_ids = [ "value" ]
      subnet_id = "value"
      ip_v4 = "value"
    }
    secret_key = "value"
  }
}

variable "aws_region" {
  description = "AWS Region"

  default     = "ap-east-1"
}

variable "github" {
  description = "Github"
  type = object({
    repo = string
  })
  default = {
    repo = "value"
  }
}

locals {
  ec2 = {
    private_key = file("${var.aws_var.private_key}")
  }
}

provider "aws" {
  access_key = "${var.aws_var.access_key}"
  secret_key = "${var.aws_var.secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_ssm_parameter" "config" {
  name  = "/ft_userdata/user_data/config.json"
  type  = "String"
  value = "${file("./${var.env}.config.json")}"
  overwrite = true
}

# resource "aws_instance" "freqtradebot" {
#   ami           = "${var.aws_var.ec2.ami}"
#   instance_type = "${var.aws_var.ec2.instance_type}"
#   subnet_id     = "${var.aws_var.ec2.subnet_id}"
#   security_groups = toset("${var.aws_var.ec2.security_group_ids}")
#   key_name      = "${var.aws_var.ec2.key_name}"
# }

provider "null" {}

resource "null_resource" "initialisation" {
  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "${var.aws_var.ec2.user}"
    private_key = "${local.ec2.private_key}"
    host        = "${var.aws_var.ec2.ip_v4}"
  }

  # provisioner "file" {
  #   source = "./user/initialisation.sh"
  #   destination = "/home/${var.aws_var.ec2.user}/initialisation.sh"
  # }
  provisioner "remote-exec" {
    inline = [
      # "chmod 777 ./initialisation.sh",
      # "./initialisation.sh ${var.aws_var.access_key} ${var.aws_var.secret_key} ${var.aws_region} ${var.github_var.repo}"
      # "sudo apt-get install gitpython3.9",
      # "sudo apt-get update",
      "aws configure set aws_access_key_id ${var.aws_var.access_key}",
      "aws configure set aws_secret_access_key ${var.aws_var.secret_key}",
      "aws configure set default.region ${var.aws_region}",
      "aws configure set default.output json",
      "docker system prune -a -f",
    ]
  }
}
resource "null_resource" "freqtradebot" {
  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    null_resource.initialisation
  ]

  connection {
    type        = "ssh"
    user        =  "${var.aws_var.ec2.user}"
    private_key = "${local.ec2.private_key}"
    host        = "${var.aws_var.ec2.ip_v4}"
  }
  # provisioner "file" {
  #   source = "./user/start.sh"
  #   destination = "/home/${var.aws_var.ec2.user}/start.sh"
  # }
  provisioner "remote-exec" {
    inline = [
      # "chmod 777 ./start.sh",
      # "./start.sh ${var.env} ${var.strategy}",
      # "git clone ${var.github_var.repo}",  # Clone repository for initiation
      "cd freqtrade",
      "git pull", # Pull repository for every push
      "chmod 777 ./run.sh && ./run.sh -i",  # Run installation script
    ]
  }
}