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
  config_path = "~/.kube/config"
}

module "jellyfin" {
  source    = "./resources/jellyfin"
  namespace = "homelab"
}

module "radarr" {
  source    = "./resources/radarr"
  namespace = "homelab"
}

module "jellyseerr" {
  source    = "./resources/jellyseerr"
  namespace = "homelab"
}

module "prowlarr" {
  source    = "./resources/prowlarr"
  namespace = "homelab"
}

module "flaresolverr" {
  source    = "./resources/flaresolverr"
  namespace = "homelab"
}

module "cluster" {
  source    = "./resources/cluster"
  namespace = "homelab"
}
