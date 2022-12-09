resource "openstack_compute_instance_v2" "instance_control_plane" {
  depends_on        = [openstack_networking_subnet_v2.subnet]
  name              = "${var.control_plane_node_machine_name}"
  image_id          = "${data.openstack_images_image_v2.image.id}"
  flavor_id         = "${data.openstack_compute_flavor_v2.flavor.id}"
  key_pair          = "${var.keypair}"
  availability_zone = "Education"
  network {
    port = "${openstack_networking_port_v2.port_ssh.id}"
  }
  user_data = "${data.template_cloudinit_config.control_plane_config.rendered}"


  provisioner "local-exec" {
    command = "ssh-keygen -R ${openstack_networking_floatingip_v2.floatingip.address}"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${data.template_file.ssh_private_key.rendered}"
    host        = "${openstack_networking_floatingip_v2.floatingip.address}"
  }    

  provisioner "file" {
    content = "${data.template_file.ssh_private_key.rendered}"
    destination = "/home/ubuntu/.ssh/ssh_private_key.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 $HOME/.ssh/ssh_private_key.pem"
    ]
  }
}

resource "openstack_compute_instance_v2" "instance_workers" {
  depends_on        = [openstack_networking_subnet_v2.subnet]
  count             = 3
  name              = "${var.worker_node_machine_name}-${count.index + 1}"
  image_id          = "${data.openstack_images_image_v2.image.id}"
  flavor_id         = "${data.openstack_compute_flavor_v2.flavor.id}"
  key_pair          = "${var.keypair}"
  security_groups   = ["default"]
  availability_zone = "Education"
  network {
    uuid = "${openstack_networking_network_v2.network.id}"
  }
  user_data = "${data.template_cloudinit_config.cloud_init_config.rendered}"
}

resource "openstack_compute_instance_v2" "nfs" {
  depends_on        = [openstack_networking_subnet_v2.subnet]
  count             = 1
  name              = "nfs"
  image_id          = "${data.openstack_images_image_v2.image.id}"
  flavor_id         = "${data.openstack_compute_flavor_v2.flavor.id}"
  key_pair          = "${var.keypair}"
  security_groups   = ["default"]
  availability_zone = "Education"
  network {
    uuid = "${openstack_networking_network_v2.network.id}"
  }

  user_data = "${data.template_cloudinit_config.nfs_init_config.rendered}"
  
  
}