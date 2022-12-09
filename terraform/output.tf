######################################################################
# Output IP Addresses

output "control_plane_machine" {
 value = "${openstack_networking_floatingip_v2.floatingip.address}, ${openstack_compute_instance_v2.instance_control_plane.access_ip_v4}"
}

output "worker_machines" {
 value = "${openstack_compute_instance_v2.instance_workers.*.access_ip_v4}"
}

output "nfs_instance" {
 value = "${openstack_compute_instance_v2.nfs.access_ip_v4}"
}