# vcenter server IP or FQDN
vcenter-server = "X.X.X.X"
# if you don't have a valid certificate in your trust store
insecure_connection  = "true"
# Define 
# datacenter, cluster, datastore, folder, network and host
# where to deploy template
datacenter = "YourDC"
cluster = "YourCluster"
datastore = "YourDatastore"
folder = "Templates"
network = "NetworkWithInternet"
host = "ESXiHostOrIP"
# if your use vault specify your kv entries for ssh and vsphere credential
vault-vsphere-key = "/kv/data/<your-vault-vcenter-kv>"
vault-ssh = "/kv/data/<your-vault-sshuser-kv>"
vault-luks = "/kv/data/<your-vault-luks-password-kv>"
# if you don't have vault, uncomment this line :
#vcenter-user = <user@domain>
## you should consider to pass this variable as 
## -var vcenter-password= 
## or export PKR_VAR_vcenter-password=****
## for security reason
#vcenter-password = <your password> 
#ssh-username = <your username>
## you should consider to pass this variable as 
## -var ssh-password= 
## or export PKR_VAR_ssh-password=****
## for security reason
#ssh-password = <your password> 
