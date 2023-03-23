variable "vcenter-server" {
    type = string
}

variable "vault-vsphere-key" {
     type = string
     sensitive = true
}

variable "vault-ssh" {
     type = string
     sensitive = true
}

variable "insecure_connection" {
    type = bool
    default = false
}

variable "datacenter" {
    type = string
}
variable "datastore" {
    type = string
}

variable "folder" {
    type = string
}

variable "cluster" {
    type = string
}

variable "network" {
    type = string
}

variable "host" {
    type = string
}

variable "rpool" {
    type = string
}

variable "shutdown_command" {
    type = string
    default = "shutdown -P now"
}
