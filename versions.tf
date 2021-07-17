terraform {
  required_providers {
    panos = {
      source = "PaloAltoNetworks/panos"
    }
  }

  backend "remote" {
    organization = "Palo_Alto"

    workspaces {
      name = "trigger"
    }
  }

  required_version = ">= 0.13"
}
