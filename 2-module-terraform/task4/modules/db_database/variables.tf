variable "cluster_id" {
  type = string
}

variable "db_name" {
  type = string
  default = "testdb"
}
variable "deletion_protection_mode" {
  type = string
  description = "Possible values: DELETION_PROTECTION_MODE_DISABLED (default), DELETION_PROTECTION_MODE_ENABLED, DELETION_PROTECTION_MODE_INHERITED"
  default = "DELETION_PROTECTION_MODE_DISABLED"
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "auth_plugin" {
  type = string
  description = <<-EOF
  Availbale values are:
  |-- MYSQL_NATIVE_PASSWORD,
  |-- CACHING_SHA2_PASSWORD,
  |-- SHA256_PASSWORD,
  |-- MYSQL_NO_LOGIN,
  |-- MDB_IAMPROXY_AUTH 
  (for version 5.7 MYSQL_NATIVE_PASSWORD, SHA256_PASSWORD, MYSQL_NO_LOGIN, MDB_IAMPROXY_AUTH)
  
  See https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin
  EOF
}