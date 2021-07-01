terraform {
required_providers {
   libvirt = {
     source="mylabs.local/local/libvirt"
     version="1.0.0"
}
}
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "centos7-qcow2" {
   name="centos7.qcow2"
   pool="default"
  # source="https://cloud.centos.org/centos/7/images/CentOS-7-x84_64-GenericCloud.qcow2"
  # source = "./CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2"
   source = "./CentOS-7-x86_64-GenericCloud.qcow2" 
  format="qcow2"
}

data "template_file" "user_data"{
  template="${file("${path.module}/cloud_init.cfg")}"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  user_data = "${data.template_file.user_data.rendered}"
}



resource "libvirt_domain" "db1" {
name="db1"
memory="1024"
vcpu=1

 network_interface {
   network_name="default"
 }

 disk {
   volume_id = "${libvirt_volume.centos7-qcow2.id}"
 }

 cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

 console {
   type="pty"
   target_type="serial"
   target_port="0"
 }

 graphics {
   type = "spice"
   listen_type = "address"
   autoport = true
 }
}

output "ip" {
value = "${libvirt_domain.db1.network_interface.0.addresses.0}"
}



