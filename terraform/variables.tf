######################################################################
# Variables

variable "keypair" {
  description = "The name of the key pair to put on the server"
  type    = string
}

variable "pem_file_path" {
  description = "The path to the PEM file."
  type    = string
}

variable "external_network_name" {
  description = "The name of the external network to be used"
  type        = string
  default     = "public"
}

variable "flavor_name" {
  description = "The name of the flavor to be used"
  type        = string
  default     = "c2-r2-d20"
}

variable "image_name" {
  description = "The name of the image to be used"
  type        = string
  default     = "Ubuntu server 22.04.1"
}

variable "base_name" {
  type    = string
  default = "k8s"
}

locals {
  network_name = "${var.base_name}-network"
  subnet_name  = "${var.base_name}-subnet"
  port_name    = "${var.base_name}-port"
  router_name  = "${var.base_name}-router"
}

variable "control_plane_node_machine_name" {
  description = "The name of the server to create"
  type    = string
  default = "k8s-control-plane"
}

variable "worker_node_machine_name" {
  description = "The prefix name of the worker node machine to create"
  type    = string
  default = "k8s-worker"
}

