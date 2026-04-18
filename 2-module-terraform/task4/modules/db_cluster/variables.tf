variable "name" {
  type = string
  default = "mysql_cluster"
  description = "Name of your cluster"
}

variable "network_id" {
  type = string
  description = "Network id to work in"
}

variable "default_cidr" {
  type = list(string)
  default = [ "10.0.4.0/24" ]
}
variable "description" {
  type = string
  default = "Mysql DB cluster"
}

variable "env" {
  type = string
  default = "PRESTABLE"
}

variable "folder_id" {
  type = string 
  default = null
}

variable "max_connections" {
  type = number
  default = 10
}

variable "sql_mode" {
  type = string
  default = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
}

variable "auth_plugin" {
  type = string
  default = "MYSQL_NATIVE_PASSWORD"
  description = <<-EOF
  Availbale values are:
  |-- MYSQL_NATIVE_PASSWORD,
  |-- SHA256_PASSWORD,
  |-- CACHING_SHA2_PASSWORD
  
  See https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin
  EOF
}

variable "HA" {
  type = bool
  default = true
}

variable "zones" {
  type = list(string)
  default = [ "ru-central1-a", "ru-central1-b" ]

  description = <<-EOF
   Should be defined 2 or more zones for HA cluster
  EOF
}

variable "subnet_cidrs" {
  type = list(list(string))
  default = [[ "10.0.1.0/24"]]
}

variable "assign_public_ip" {
  type = bool
  default = true
}


variable "resouces" {
  type = object({
    resource_preset_id = string
    disk_type_id       = string
    disk_size          = number
  })
  default = {
    resource_preset_id = "b1.medium"
    disk_type_id = "network-hdd"
    disk_size = 10
  }
  description = <<-EOT
These parameters define the hardware "muscle" and storage capabilities of your MySQL cluster hosts. 
1. resource_preset_id (Compute Power)
   This ID determines the CPU and RAM allocation for each host in your cluster. 

  Presets: 
    * s2.micro (2 vCPU, 8 GB RAM)
    * b1.medium (2 vCPU with 50% burst, 4 GB RAM).

2. disk_type_id (Storage Performance)
This defines the physical or network storage technology used. 

    * network-hdd: Most cost-effective; best for small databases or development.
    * network-ssd: Standard choice; balanced performance with data redundancy.
    * network-ssd-nonreplicated: High performance but requires at least 3 hosts for high availability because it lacks network-level redundancy.
    * local-ssd: Highest performance (physically attached to the server); also requires at least 3 hosts and has specific size increment rules. 

3. disk_size (Storage Capacity)
The amount of storage space allocated to each host, typically measured in GB. 

    *Minimums*: Starts at 10 GB for network storage.
    *Increments*: The step size for increasing storage depends on the disk_type_id. 
    *For example*, network-ssd can grow in 1 GB steps, 
                 local-ssd requires larger increments (e.g., 100 GB or 368 GB depending on the processor platform).
    **Safety Tip**: If a disk reaches 95% capacity, the cluster automatically switches to read-only mode. 
  EOT
}
