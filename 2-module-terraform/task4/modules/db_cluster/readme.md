## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | >= 0.47.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | >= 0.47.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [yandex_mdb_mysql_cluster.ayn_db_cluster](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_cluster) | resource |
| [yandex_vpc_subnet.default_subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_auth_plugin"></a> [auth\_plugin](#input\_auth\_plugin) | availbale values are: mysql\_native\_password, sha256\_password, caching\_sha2\_password. See https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin | `string` | `"sha256_password"` | no |
| <a name="input_default_cidr"></a> [default\_cidr](#input\_default\_cidr) | n/a | `list(string)` | <pre>[<br/>  "10.0.1.0/24"<br/>]</pre> | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `"Mysql DB cluster"` | no |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | `"PRESTABLE"` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | n/a | `string` | `null` | no |
| <a name="input_host_zone"></a> [host\_zone](#input\_host\_zone) | n/a | `string` | `"ru-central1-a"` | no |
| <a name="input_hosts"></a> [hosts](#input\_hosts) | Tips:<br/>  * If you provide more than one host block (manually or via dynamic), <br/>  the cluster is automatically considered High Availability (HA).<br/>  * Every `subnet_id` used in the host blocks must belong to <br/>  the same `network_id` defined at the cluster level. | <pre>list(object({<br/>    zone      = string<br/>    subnet_id = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "zone": "ru-cantral1-a"<br/>  }<br/>]</pre> | no |
| <a name="input_max_connections"></a> [max\_connections](#input\_max\_connections) | n/a | `number` | `2` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of your cluster | `string` | `"mysql_cluster"` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | Network id to work in | `string` | n/a | yes |
| <a name="input_resouces"></a> [resouces](#input\_resouces) | These parameters define the hardware "muscle" and storage capabilities of your MySQL cluster hosts. <br/>1. resource\_preset\_id (Compute Power)<br/>   This ID determines the CPU and RAM allocation for each host in your cluster. <br/><br/>  Presets: <br/>    * s2.micro (2 vCPU, 8 GB RAM)<br/>    * b1.medium (2 vCPU with 50% burst, 4 GB RAM).<br/><br/>2. disk\_type\_id (Storage Performance)<br/>This defines the physical or network storage technology used. <br/><br/>    * network-hdd: Most cost-effective; best for small databases or development.<br/>    * network-ssd: Standard choice; balanced performance with data redundancy.<br/>    * network-ssd-nonreplicated: High performance but requires at least 3 hosts for high availability because it lacks network-level redundancy.<br/>    * local-ssd: Highest performance (physically attached to the server); also requires at least 3 hosts and has specific size increment rules. <br/><br/>3. disk\_size (Storage Capacity)<br/>The amount of storage space allocated to each host, typically measured in GB. <br/><br/>    *Minimums*: Starts at 10 GB for network storage.<br/>    *Increments*: The step size for increasing storage depends on the disk\_type\_id. <br/>    *For example*, network-ssd can grow in 1 GB steps, <br/>                 local-ssd requires larger increments (e.g., 100 GB or 368 GB depending on the processor platform).<br/>    **Safety Tip**: If a disk reaches 95% capacity, the cluster automatically switches to read-only mode. | <pre>object({<br/>    resource_preset_id = string<br/>    disk_type_id       = string<br/>    disk_size          = number<br/>  })</pre> | <pre>{<br/>  "disk_size": 16,<br/>  "disk_type_id": "network-hdd",<br/>  "resource_preset_id": "s2.micro"<br/>}</pre> | no |
| <a name="input_sql_mode"></a> [sql\_mode](#input\_sql\_mode) | n/a | `string` | `"ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Network subnet id to work in | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_name"></a> [name](#output\_name) | n/a |
