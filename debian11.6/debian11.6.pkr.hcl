# ubuntu 21.04 template, by default use password store in vault
# uncomment none vaut password to with standard password
# to use vault export your VAULT_TOKEN and VAULT_ADDR as bash variable before run packer

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

#source bloc
source "vsphere-iso" "debian11_6_preseed" {
  #VM definition
  vm_name              = "Debian-11.6-amd64-v1"
  notes                = "build template v01 debian 11.6 via preseed"  
  #iso ubuntu 20.10 autoinstall
  iso_checksum         = "sha512:224cd98011b9184e49f858a46096c6ff4894adff8945ce89b194541afdfd93b73b4666b0705234bd4dff42c0a914fdb6037dd0982efb5813e8a553d8e92e6f51"
  iso_urls             = ["iso/debian-11.6.0-amd64-netinst.iso", "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.6.0-amd64-netinst.iso"]

  convert_to_template  = "true"
  vm_version           = "17"
  CPUs                 = "1"
  RAM                  = "4096"
  RAM_reserve_all      = "false"
  #guest_os_type        = "debian11_64Guest"
  guest_os_type        = "other4xLinux64Guest"
  firmware	       = "efi-secure"
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = "32768"
    disk_thin_provisioned = "true"
  }
  network_adapters {
    network      = "${var.network}"
    network_card = "vmxnet3"
  }
  
  
  #Boot command we use CDROM for autoinstall
  boot_command = [
      "<wait>",
      "<down><down><enter>",
      "<down><down><down><down><down><enter>",
      "<wait30s>",
      "<leftAltOn><f2><leftAltOff>",
      "<enter><wait>",
      "mount /dev/sr1 /media<enter>",
      "<leftAltOn><f1><leftAltOff>",
      "file:///media/./preseed.cfg",
      "<enter><wait>"
  ]
  #boot_command           = ["<esc><esc><esc>","<enter><wait>","/casper/vmlinuz ","initrd=/casper/initrd ","autoinstall autoinstall ","<enter>"]
  boot_order             = "disk,cdrom,floppy"
  boot_wait              = "5s"
  cd_files               = ["./cdrom/preseed.cfg"]
  cd_label               = "cidata"
  #if uncommented http server is on
  #http_directory         = "http-dir"

  #vsphere definition
  vcenter_server         = "${var.vcenter_server}"
  #username               = "${var.vcenter-user}""
  username               = vault("${var.vault-vsphere-key}", "login")
  #password               = "${var.vcenter-password}"
  password               = vault("${var.vault-vsphere-key}", "password")
  insecure_connection    = "${var.insecure_connection}"
  datacenter             = "${var.datacenter}"
  cluster                = "${var.cluster}"
  host                   = "${var.host}"
  datastore              = "${var.datastore}"
  folder                 = "${var.folder}"
 
  #Communicator part for doing stuff after installation before convert to template
  communicator           = "ssh"
  #communicator           = "none"
  shutdown_timeout       = "120m"
  
  ssh_handshake_attempts = "300"
  ssh_pty                = true
  ssh_timeout            = "120m"
  #ssh_username           = "${var.ssh-username}"
  ssh_username           = vault("${var.vault-ssh}", "username")
  #ssh_password           = "${var.ssh-password}"
  ssh_password           = vault("${var.vault-ssh}", "password")
  ip_settle_timeout      = "5m"
  #uncomment if you have trouble with shutdown as standard user
  #choose between with vault password or not
  #shutdown_command       = "echo ${vault("${var.vault-ssh}", "password")} | shutdown -P now"
  #shutdown_command       = "echo ${var.ssh-password} | shutdown -P now"

}

build {
  sources = ["source.vsphere-iso.debian11_6_preseed"]

  provisioner "file"{
   source = "scripts/cleanup_script.sh"
   destination = "/tmp/cleanup_script.sh"
   }
  
  provisioner "shell"{
   remote_folder = "/tmp"
   #inline = [
   #  "echo ${var.sshpassword} |sudo -S bash /tmp/cleanup_script.sh"
   #  ]
   inline = [
     "echo ${vault("${var.vault-ssh}", "password")} |sudo -S bash /tmp/cleanup_script.sh"
     ]
   }

}
