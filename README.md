# packerTemplates

This repository contain my packer templates

Availlable templates :
* Debian 11.6 with cloud-init support
* Ubuntu 20.04 using autoinstall
* Ubuntu 20.10 using autoinstall
* Ubuntu 21.04 using autoinstall


# Configuration before run packer

This templates store password in vault from hashicorp by default. If your don't use Vault from hashicorp you have to make some change in the template.

## for linux template

### if you use vault

create two kv entries one for vcenter containing user/password for vcenter and one for ssh user containing user/password
* kv for vcenter :
** login/password
* kv for ssh login :
** username/password

and fill them into Infra.pkrvar.hcl

```HCL
vault-vsphere-key = "/kv/data/<your-vault-vcenter-kv>"
vault-ssh = "/kv/data/<your-vault-sshuser-kv>"
```

### if you don't use vault

If you don't want to use vault you have to comment the following variables in the file "ubuntu-2Y.XX-live-server-packer.pkr.hcl"

```HCL
username               = vault("${var.vault-vsphere-key}", "login")
password               = vault("${var.vault-vsphere-key}", "password")
ssh_username           = vault("${var.vault-ssh}", "username")
ssh_password           = vault("${var.vault-ssh}", "password")
```

and uncomment the following one 

```HCL
username               = "${var.vcenter-user}""
password               = "${var.vcenter-password}"
ssh_username           = "${var.ssh-username}"
ssh_password           = "${var.ssh-password}"
```

Then you have to comment in Infra.pkrvar.hcl the following line :

```HCL
vault-vsphere-key = "/kv/data/<your-vault-vcenter-kv>"
vault-ssh = "/kv/data/<your-vault-sshuser-kv>"
```

and uncomment the following lines :

```HCL
#vcenter-user = <user@domain>
#ssh-username = <your username>
```

you also have to set vcenter-password and ssh-password but for security reason you should consider to pass this variable as BASH variable or using -var vcenter-password=xxxxx -var ssh-password=xxxxxxxx with packer command line

As BASH variable :

```bash
export PKR_VAR_vcenter-password=****
export PKR_VAR_ssh-password=****
```

### generate password for ubuntu autoinstall

autoinstall use user-data for unattended installation. This file is located under the cdrom folder, you need to change username and password according in the identity section in this file.

by default username/password : ubuntu/ubuntu

```bash
  identity:
    hostname: u2104srv
    username: ubuntu #your username
    password: "$6$vFyT28T96pT$VsbpaDOHslHFKvvGkSnqmXTrstPDOo6slUhMm5YHUJowzeDllXgekked9aEOWEP8ptT9Q38uG371n97HJXN4f/" #ubuntu
```
under scripts your got user_data_pass_sed.sh to help you edit this file quickly

```bash
# to supply username and password from command line
bash user_data_pass_sed.sh -u osadmin -p ubuntu

# to use vault key value secrets
bash -x user_data_pass_sed.sh -k kv/myvaultkv
```

Don't forget to have the same value in Infra.pkrvar.hcl and ubuntu-2Y.XX-live-server-packer.pkr.hcl files

Don't forget to also fil Infra.pkvar.hcl with your vSphere info (vDC,Cluster,Datastore,Network), the network need to have internet acces and a DHCP, if you don't have a DHCP your could set IP in user-data :

change :
```
  network:
    network:
      version: 2
      ethernets:
        ens192:
          dhcp4: true
```
by :

```
  network:
    network:
      version: 2
      ethernets:
        enwild:
          match:
            name: en*
          addresses:
            - X.X.X.X/YY
          dhcp4: false
          gateway4: X.X.X.X
          nameservers:
            addresses:
              - X.X.X.X
```

If you want to make offline template, you will need to :
* change in autoinstall to switch to your internal apt repository
* grap https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh script and convert it offline

# build your template

if you use VAULT don't forget to export as BASH variable  VAULT_ADDR end VAULT_TOKEN

```bash
# go inside the template your wants and run packer
packer build -var-file=Infra.pkrvar.hcl .
```

