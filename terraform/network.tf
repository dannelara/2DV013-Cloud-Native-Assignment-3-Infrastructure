######################################################################
# Create a router

resource "openstack_networking_router_v2" "router" {
  name = "${local.router_name}"
  external_network_id = "${data.openstack_networking_network_v2.extnet.id}"
}

######################################################################
# Create networks

resource "openstack_networking_network_v2" "network" {
  name = "${local.network_name}"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "${local.subnet_name}"
  network_id = "${openstack_networking_network_v2.network.id}"
  cidr       = "172.16.0.0/16"
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = "${openstack_networking_router_v2.router.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
}

######################################################################
# Create a SSH security group

resource "openstack_networking_secgroup_v2" "secgroup_ssh" {
  name        = "ssh"
  description = "Allow SSH traffic"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_ssh.id}"
}

resource "openstack_networking_secgroup_v2" "secgroup_nfs" {
  name        = "nfs"
  description = "Allow 2049 traffic"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_nfs" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2049
  port_range_max    = 2049
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_nfs.id}"
}

######################################################################
# Create a port

resource "openstack_networking_port_v2" "port_ssh" {
  name               = "${local.port_name}"
  network_id         = "${openstack_networking_network_v2.network.id}"
  security_group_ids = [
    "${data.openstack_networking_secgroup_v2.secgroup_default.id}",
    "${openstack_networking_secgroup_v2.secgroup_ssh.id}"
  ]
  admin_state_up     = "true"
  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
  }
}

######################################################################
# Get a floating IP

resource "openstack_networking_floatingip_v2" "floatingip" {
  pool = "public"
}

######################################################################
# Associate the floating IP to the port

resource "openstack_networking_floatingip_associate_v2" "floatingip_association" {
  floating_ip = "${openstack_networking_floatingip_v2.floatingip.address}"
  port_id = "${openstack_networking_port_v2.port_ssh.id}"
}
