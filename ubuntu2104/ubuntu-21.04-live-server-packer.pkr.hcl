# ubuntu 21.04 template, by default use password store in vault
# uncomment none vaut password to with standard password
# to use vault export your VAULT_TOKEN and VAULT_ADDR as bash variable before run packer

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

#source bloc
source "vsphere-iso" "u2104_autoinstall" {
  #VM definition
  vm_name              = "ubuntu-2104-amd64-v1"
  notes                = "build template v01 ubuntu 2104 via autoinstall"  
  #iso ubuntu 20.10 autoinstall
  iso_checksum         = "sha256:e4089c47104375b59951bad6c7b3ee5d9f6d80bfac4597e43a716bb8f5c1f3b0"
  iso_urls             = ["iso/ubuntu-21.04-live-server-amd64.iso", "https://releases.ubuntu.com/21.04/ubuntu-21.04-live-server-amd64.iso"]

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
    network      = "${var.network}"
    network_card = "vmxnet3"
  }
  
  #Boot command we use CDROM for autoinstall
  boot_command = [
   "<tab><tab><tab><tab><tab><c><wait><bs><bs>",
    "set gfxpayload=keep", "<enter>",
    "linux /casper/vmlinuz quiet autoinstall ---", "<enter>",
    "initrd /casper/initrd", "<enter>",
    "boot",  "<enter>"
     ]
  #boot_command           = ["<esc><esc><esc>","<enter><wait>","/casper/vmlinuz ","initrd=/casper/initrd ","autoinstall autoinstall ","<enter>"]
  boot_order             = "cdrom,disk,floppy"
  boot_wait              = "5s"
  cd_files               = ["./cdrom/meta-data","./cdrom/user-data"]
  cd_label               = "cidata"
  #if uncommented http server is on
  #http_directory         = "http-dir"

  #vsphere definition
  vcenter_server         = "${var.vcenter-server}"
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
  #shutdown_timeout       = "30m"
  ssh_handshake_attempts = "300"
  ssh_pty                = true
  ssh_timeout            = "15m"
  #ssh_username           = "${var.ssh-username}"
  ssh_username           = vault("${var.vault-ssh}", "username")
  #ssh_password           = "${var.ssh-password}"
  ssh_password           = vault("${var.vault-ssh}", "password")
  ip_settle_timeout      = "10m"
  #uncomment if you have trouble with shutdown as standard user
  #choose between with vault password or not
  #shutdown_command       = "echo ${vault("${var.vault-ssh}", "password")} | shutdown -P now"
  #shutdown_command       = "echo ${var.ssh-password} | shutdown -P now"

}

build {
  sources = ["source.vsphere-iso.u2104_autoinstall"]

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
