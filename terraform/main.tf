terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "kubernetes" {
  config_path = "/etc/rancher/k3s/k3s.yaml"
}

module "jellyfin" {
  source = "./resources/jellyfin"
}

module "radarr" {
  source = "./resources/radarr"
}
