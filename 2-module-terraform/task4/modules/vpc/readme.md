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
| [yandex_vpc_network.vpc_network](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network) | resource |
| [yandex_vpc_subnet.vpc_subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Will be used in name templates of network and it's subnet | `string` | `"development"` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | Provider folder you are going to work in | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | n/a | <pre>list(object(<br/>    {<br/>      cidr = string<br/>      zone = string<br/>    }<br/>  ))</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Returns information about created subnets |
