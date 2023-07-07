terraform {
	required_providers {
		linode = {
			source	= "linode/linode"
		}
    tailscale = {
      source  = "tailscale/tailscale"
    }
	}
}

provider "linode" {
	token = "${var.linode_token}"
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailscale_tailnet
}
