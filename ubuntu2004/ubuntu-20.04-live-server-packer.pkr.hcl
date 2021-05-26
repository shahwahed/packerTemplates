locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

#source bloc
source "vsphere-iso" "u2004_autoinstall" {
  #VM definition
  vm_name              = "ubuntu-2004-amd64-v01"
  notes                = "build template v01 ubuntu 2004 via autoinstall"  
  #iso ubuntu 20.04 legacy
  #iso_checksum         = "sha256:f11bda2f2caed8f420802b59f382c25160b114ccc665dbac9c5046e7fceaced2"
  #iso_urls             = ["iso/ubuntu-20.04.1-legacy-server-amd64.iso", "http://cdimage.ubuntu.com/ubuntu-legacy-server/releases/20.04/release/ubuntu-20.04.1-legacy-server-amd64.iso"]
  #iso ubuntu 20.04 autoinstall
  iso_checksum         = "sha256:d1f2bf834bbe9bb43faf16f9be992a6f3935e65be0edece1dee2aa6eb1767423"
  iso_urls             = ["iso/ubuntu-20.04.2-live-server-amd64.iso", "https://releases.ubuntu.com/20.04/ubuntu-20.04.2-live-server-amd64.iso"]

  convert_to_template  = "true"
  vm_version           = "14"
  CPUs                 = "1"
  RAM                  = "4096"
  RAM_reserve_all      = "false"
  guest_os_type        = "ubuntu64Guest"
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = "32768"
    disk_thin_provisioned = "true"
  }
  network_adapters {
    network      = "VM Network"
    network_card = "vmxnet3"
  }
  
  #Boot command for http/https preseed
  #boot_command           = [" <wait><enter><wait>", "<f6><esc>", "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "<bs><bs><bs>", "/install/vmlinuz ", "initrd=/install/initrd.gz ", "priority=critical ", "ipv6.disable=1 ", "auto=true  url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu-20.04/server.20.04.preseed.cfg", "<enter>"]
  #Boot command we use CDROM for autoinstall
  boot_command           = ["<esc><esc><esc>","<enter><wait>","/casper/vmlinuz ","initrd=/casper/initrd ","autoinstall ","<enter>"]
  boot_order             = "cdrom,disk,floppy"
  boot_wait              = "5s"
  cd_files               = ["./cdrom/meta-data","./cdrom/user-data"]
  cd_label               = "cidata"
  #if uncommented http server is on
  #http_directory         = "http-dir"

  #vsphere definition
  vcenter_server         = "${var.vcenter-server}" 
  username               = vault("${var.vault-vsphere-key}", "login")
  password               = vault("${var.vault-vsphere-key}", "password")
  insecure_connection    = "${var.insecure_connection}"
  datacenter             = "${var.datacenter}"
  cluster                = "${var.cluster}"
  host                   = "${var.host}"
  datastore              = "${var.datastore}"
  folder                 = "${var.folder}"
 
  #Communicator part for doing stuff after installation before convert to template
  communicator           = "ssh"
  ssh_handshake_attempts = "300"
  ssh_pty                = true
  ssh_timeout            = "15m"
  ssh_username           = vault("${var.vault-ssh}", "username")
  ssh_password           = vault("${var.vault-ssh}", "password")
  ip_settle_timeout      = "4m"
  #shutdown_command       = "echo ${vault("${var.vault-ssh}", "password")} | shutdown -P now"
  #shutdown_command       = "shutdown -P now"

}

build {
  sources = ["source.vsphere-iso.u2004_autoinstall"]

  provisioner "file"{
    source = "scripts/cleanup_script.sh"
    destination = "/tmp/cleanup_script.sh"
    }
  
  provisioner "shell"{
    remote_folder = "/tmp"
    inline = [
      "echo ${vault("${var.vault-ssh}", "password")} |sudo -S bash /tmp/cleanup_script.sh"
      ]
    }

}
