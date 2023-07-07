variable "linode_token" {}

variable "tailscale_auth_key" {}

variable "tailscale_api_key" {}

variable "tailscale_tailnet" {
	default = "xxxxxx.ts.net"
}

variable "tailnet_name" {
	default = "example@tailscale.com"
}

variable "node_count" {
	default = 2
}

variable "regions" {
  default = ["us-southeast", "ap-south"]
}

variable "vpn" {
	default = {
		image = "linode/ubuntu22.04"
		type = "g6-standard-1"
		group = "vpn"
	}
}

variable "vlan" {
	default = {
		label = "tailscale-vlan"
		purpose = "vlan"
	}
}

variable "ip" {
  default = {
    "us-southeast" = "10.0.1"
    "ap-south" = "10.0.0"
  }
}

variable "peer_network" {
  type = map
  default = {
    "us-southeast" = "10.0.0"
    "ap-south" = "10.0.1"
  }
}

variable "public_ssh_key" {
  default     = "~/.ssh/key.pub"
}

resource "random_string" "password" {
	length = 32
	special = true
	upper = true
	lower = true
	numeric = true
}

