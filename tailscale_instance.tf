resource "linode_instance" "vpn" {
	count =  length(var.regions) * var.node_count
	label = "tailscale-${element(var.regions, count.index % length(var.regions))}-${floor(count.index / var.node_count) + 1}"
	image = var.vpn.image
  region = element(var.regions, count.index % length(var.regions))
	type = var.vpn.type
	authorized_keys = ["${chomp(file(var.public_ssh_key))}"]

	group = var.vpn.group
	swap_size = 256
	root_pass = random_string.password.result
	private_ip = false

  interface {
    purpose = "public"
  }

	interface {
    purpose = var.vlan.purpose
    label = var.vlan.label
    ipam_address = "${var.ip[element(var.regions, count.index % length(var.regions))]}.${floor(count.index / var.node_count) + 1}/24"
  }
	
	provisioner "remote-exec" {
		inline = [
			"hostnamectl set-hostname tailscale-${element(var.regions, count.index % length(var.regions))}-${floor(count.index / var.node_count) + 1}",
      "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.ipv4.conf.eth0.disable_xfrm=1' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.ipv4.conf.eth0.disable_policy=1' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.ipv4.conf.eth1.disable_xfrm=1' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.ipv4.conf.eth1.disable_policy=1' | sudo tee -a /etc/sysctl.conf",
      "sudo sysctl -p",
			"curl -fsSL https://tailscale.com/install.sh | sh",
      "tailscale up --authkey ${var.tailscale_auth_key} --hostname=tailscale-${element(var.regions, count.index % length(var.regions))}-${floor(count.index / var.node_count) + 1} --advertise-routes=${var.ip[element(var.regions, count.index % length(var.regions))]}.0/24 --accept-routes --ssh",
			"apt-get update",
 			"apt-get install -y keepalived",
      "echo 'vrrp_instance Instance1 {' | sudo tee /etc/keepalived/keepalived.conf",
      "echo '    state ${count.index == 0 || count.index == 1 ? "MASTER" : "BACKUP"}' | sudo tee -a /etc/keepalived/keepalived.conf",
      "echo '    interface eth1' | sudo tee -a /etc/keepalived/keepalived.conf",
      "echo '    virtual_router_id 10' | sudo tee -a /etc/keepalived/keepalived.conf",
      "echo '    priority ${count.index == 0 || count.index == 1 ? "100" : "50"}' | sudo tee -a /etc/keepalived/keepalived.conf",
      "echo '    advert_int 1' | sudo tee -a /etc/keepalived/keepalived.conf",
      "echo '    authentication {' | sudo tee -a /etc/keepalived/keepalived.conf",
      "echo '        auth_type PASS' | sudo tee -a /etc/keepalived/keepalived.conf",
      "echo '        auth_pass password' | sudo tee -a /etc/keepalived/keepalived.conf",
      "echo '    }' | sudo tee -a /etc/keepalived/keepalived.conf",
      "echo '    virtual_ipaddress {' | sudo tee -a /etc/keepalived/keepalived.conf",
      "echo '        ${var.ip[element(var.regions, count.index % length(var.regions))]}.254' | sudo tee -a /etc/keepalived/keepalived.conf",
      "echo '    }' | sudo tee -a /etc/keepalived/keepalived.conf",
      "echo '}' | sudo tee -a /etc/keepalived/keepalived.conf",
      "sudo systemctl enable keepalived && sudo systemctl start keepalived",
		]

		connection {
			type = "ssh"
			user = "root"
			password = random_string.password.result
			host = self.ip_address
		}
	}
}
