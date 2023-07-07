resource "linode_instance" "icmp" {
  count = length(var.regions)
  label = "icmp-instance-${element(var.regions, count.index)}"
  image = var.vpn.image
  region = element(var.regions, count.index)
  type = var.vpn.type
  authorized_keys = ["${chomp(file(var.public_ssh_key))}"]

  group = "icmp-instances"
  swap_size = 256
  root_pass = random_string.password.result
  private_ip = false

  interface {
    purpose = "public"
  }

  interface {
    purpose = var.vlan.purpose
    label = var.vlan.label
    ipam_address = "${var.ip[element(var.regions, count.index)]}.10/24"
  }

  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname icmp-instance-${element(var.regions, count.index)}",
      "sudo ip route add ${var.peer_network[element(var.regions, count.index)]}.0/24 via ${var.ip[element(var.regions, count.index)]}.254",
    ]
		connection {
      type = "ssh"
      user = "root"
      password = random_string.password.result
      host = self.ip_address
    }
  }
}
