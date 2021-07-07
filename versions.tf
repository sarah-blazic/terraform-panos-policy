terraform {
  required_providers {
    panos = {
      source = "PaloAltoNetworks/panos"
    }
  }
  required_version = ">= 0.13"

  backend "remote" {
    organization = "Palo_Alto"

    workspaces {
      name = "trigger"
    }
  }
}
