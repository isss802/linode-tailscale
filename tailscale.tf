data "tailscale_device" "vpn" {
  count = length(var.regions) * var.node_count
  name = "tailscale-${element(var.regions, count.index % length(var.regions))}-${floor(count.index / var.node_count) + 1}.${var.tailnet_name}"
  depends_on = [linode_instance.vpn]
}

resource "tailscale_device_subnet_routes" "vpn_routes" {
  count = length(var.regions) * var.node_count
  device_id = data.tailscale_device.vpn[count.index].id
  routes = [
    "${var.ip[element(var.regions, count.index % length(var.regions))]}.0/24"
  ]
  depends_on = [linode_instance.vpn]
}
