variable "vsphere_user" {
  default = "svc_tf@prob.local"
}

variable "vsphere_password" {
  default = "Terraform!23"
}

variable "vsphere_server" {
  default = "probvcsa01.prob.local"
}

variable "vsphere_datastore" {
  default = "vsanDatastore"
}

variable "vsphere_rp" {
  default = "Prob-HL/Resources/Workloads"
}

variable "vsphere_network" {
  default = "VM Network"
}

variable "folder_name" {
  default = "Home_Lab"
}

variable "vm_name" {
  default = "chefdemo01"
}

variable "pw" {
  default = "Password!"
}

variable "ip" {
  default = "192.168.1.161"
}

variable "user_pem" {}
