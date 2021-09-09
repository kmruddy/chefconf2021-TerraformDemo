terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.0.2"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {}

data "vsphere_datastore" "vsan" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "wkld" {
  name          = var.vsphere_rp
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "vmnet" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_folder" "vm_folder" {
  path = var.folder_name
}

data "vsphere_virtual_machine" "template" {
  name          = "Ubuntu18-Template"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_resource_pool.wkld.id
  datastore_id     = data.vsphere_datastore.vsan.id
  folder           = data.vsphere_folder.vm_folder.path
  # wait_for_guest_net_timeout = 0

  num_cpus = 1
  memory   = 1024
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.vmnet.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.vm_name
        domain    = "prob.local"
      }

      network_interface {
        ipv4_address = var.ip
        ipv4_netmask = 24
      }
      dns_server_list = ["192.168.1.22", "192.168.1.10"]
      ipv4_gateway    = "192.168.1.254"
    }
  }
}

resource "null_resource" "run_chef" {
  depends_on = [vsphere_virtual_machine.vm, ]

  connection {
    type     = "ssh"
    user     = "root"
    password = var.pw
    host     = var.ip
  }

  provisioner "chef" {
    client_options = ["chef_license 'accept'"]
    node_name      = "chefdemo01"
    server_url     = "https://api.chef.io/organizations/tfdemo"
    user_name      = "kmruddy"
    user_key       = var.user_pem
    run_list       = ["role[sample_role]"]
  }
}
