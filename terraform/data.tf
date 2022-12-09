######################################################################
# Data sources

data "template_file" "ssh_private_key" {
  template = file("${var.pem_file_path}")
}

## Get Image ID
data "openstack_images_image_v2" "image" {
  name        = "${var.image_name}"
  most_recent = true
}

## Get flavor id
data "openstack_compute_flavor_v2" "flavor" {
  name = "${var.flavor_name}"
}

## Get external network ID
data "openstack_networking_network_v2" "extnet" {
  name = "${var.external_network_name}"
}

data "openstack_networking_secgroup_v2" "secgroup_default" {
  name        = "default"
}

data "template_cloudinit_config" "cloud_init_config" {
  part {
    content_type = "text/cloud-config"
    content = "${file("./scripts/cloud-init.yaml")}"
  }
}

data "template_cloudinit_config" "control_plane_config" {
  part {
    content_type = "text/cloud-config"
    content = "${file("./scripts/cloud-init.yaml")}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content = "${file("./scripts/control-plane-init.yaml")}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}

data "template_cloudinit_config" "nfs_init_config" {
  part {
    content_type = "text/cloud-config"
    content = "${file("./scripts/nfs-init.yaml")}"
  }
}