packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.1.1"
      source = "github.com/hashicorp/googlecompute"
    }
  }
}

variable "project_id" {
  type = string
}

variable "zone" {
  type = string
}

variable "builder_sa" {
  type = string
}

source "googlecompute" "test-image" {
  project_id                  = var.project_id
  source_image_family         = "ubuntu-2204-lts"
  zone                        = var.zone
  image_description           = "Created with HashiCorp Packer from Cloudbuild"
  ssh_username                = "packer"
  tags                        = ["packer"]
  impersonate_service_account = var.builder_sa
  image_name                  = "dev-workspace-${formatdate("YYYYMMDD-hhmm", timestamp())}"
}

build {
  sources = ["source.googlecompute.test-image"]
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo add-apt-repository ppa:longsleep/golang-backports",
      "sudo apt-get install -y golang-go python3 python3-pip",
      "go version",
      "python3 --version"
    ]
  }
}