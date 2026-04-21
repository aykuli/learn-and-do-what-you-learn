# [Домашнее задание к занятию «Использование Terraform в команде»](https://github.com/netology-code/ter-homeworks/blob/main/05/hw-05.md)

Содержание:
* [Задание 1](#задание-1)

    * [tflint](#tflint)
    * [checkov](#checkov)
* [Задание 2](#задание-2)
* [Задание 3](#задание-3)
* [Задание 4](#задание-4)

## Задание 1

### tflint

Установила `tflint`. В главной [репе](https://github.com/terraform-linters/tflint#getting-started) пишут, что по умолчанию скомпилироано: "recommended" preset by default, но есть возможность переопределения через файл `.tflint.hcl`.

Зайдём в папку [src](https://github.com/netology-code/ter-homeworks/tree/main/04/src):
![](./assets/1-1.png)

Warnings и их описание приведены сразу с ссылкой. Текст ошибки проекта `src` ругается:
 - забыл указать версию провайдера `yandex` файле `providers.tf` на линии 3:
Необходимо например:

```
required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "1.0.0"
    }
  }
```
 - переменная `"vms_ssh_root_key"` зря что ли была указана в `variables.tf` на линии 36, и не заюзана?
 - переменная `"vm_web_name"` тоже бесхозна в `variables.tf `на линии 43?
 - переменная `"vm_db_name"` тоже плачет в `variables.tf` на линии 50?

![](./assets/1-2.png)

Текст ошибки проекта `demonstration1/vms` говорит:
 - если не взять определенную версию модуля из репозитория, то просто привязка к ветке может привести к проблемам, если кто-нибудь на том конце (в репе) волъет изменения в указанную в `source` ветку. Поэтому рекомендуется привязать источник к определенной версии и указать что-то похожее на: `"git::https://github.com/udjin10/yandex_compute_instance.git?ref=v1.1.0"`
 - забыл указать версию провайдера `template` файле `providers.tf` на линии 3:
Необходимо что-то такое:

```terraform
terraform {
  required_providers {
    template = {
      source  = "hashicorp/template"
      version = "~> 2"
    }
  }
}
```
 - переменная `"public_key"` зря указана в `variables.tf` на линии 3, и не заюзана, и чувствует себя пустой и ненужной.

![](./assets/1-3.png)

Текст одной единственной ошибки проекта `demonstration1/passwords` говорит:

- не указан провайдер ресурса `random_password`, необходимо бы добавить в провайдеры:
```terraform
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0" # Specify the version constraint here
    }
  }
}
```

![](./assets/1-4.png)

С установленным плагином теперь невписывающийся в линтер код будет сразу мозолить глаза.

### checkov

Проверяю сикреты  с `checkov`. 
2 папки показали, что всё хорошо, с его точки зрения.
![](./assets/1-5.png)

А вот в этой папке vms есть ошибки опять же указывающие на то, что необходимо использоать тег в репе, вместо ветки?
Я там для теста написала, как будто в репе есть тег, и я на него ссылаюсь. В этом месте, ессно, нет ошибки про ссылку на ветку репы.
и почему-то опросит использоать коммит в source модуля. Про это есть исусе в гитхабе - [https://github.com/bridgecrewio/checkov/issues/5366](https://github.com/bridgecrewio/checkov/issues/5366). Закрытый, но видимо не решённый 💁🏻.
![](./assets/1-6.png)

## Задание 2

![](./assets/2-2.png)
![](./assets/2-3.png)

В бакете появилась папочка проекта со стейтом.
![](./assets/2-4.png)
До этого я сервисному аккунту `ayn-netology-sa` добавила роль `storage.uploader`. Роль `storage.uploader` позволяет загружать объекты в бакеты, в том числе перезаписывать загруженные ранее, а также читать данные в бакетах, просматривать информацию о бакетах и объектах в них, а также о каталоге и квотах сервиса Object Storage. Не позволяет удалять объекты и конфигурировать бакеты.

![](./assets/2-5.png)

## Задание 3

[Pull request с фиксами по результату сканирования с `checkov` и `tflint`](https://github.com/aykuli/learn-and-do-what-you-learn/pull/4)

![](./assets/3-3.png)
Для checkov я использоала такую настройку для всех папок.

<details>
<summary>Было</summary>

![](./assets/3-1.png)
![](./assets/3-2.png)
![](./assets/3-4.png)
![](./assets/3-1.png)

</details>

<details>
<summary>Стало</summary>

![](./assets/3-5.png)
![](./assets/3-6.png)
![](./assets/3-7.png)

</details>

## Задание 4

[Код](./mock_project/main.tf)

<details>
<summary>varibales blocks</summary>

```bash
variable "ip" {
  type = string
  description = "ip-адрес"
  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.ip))
    error_message = "Значение IP ты ввела неправильно, посмотри свои объявления переменных в *.auto.tfvars, может опечалатась?"
  }
}

variable "ip_addresses" {
  type = list(string)
  description = "список ip-адресов"
  validation {
    condition = alltrue([
      for ip in var.ip_addresses : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
    ])
    error_message = "В одной из адресов есть ошибка, в какой не знаю, сама ищи."
  }
}
```
</details>

![](./assets/4-1.png)

## Задание 5*

[Код](./mock_project/main.tf#L34)

<details>
<summary>varibales blocks</summary>

```bash
variable "lower_str" {
  type = string
  description = "line with only lower letters"
  validation {
    condition = length(regexall("[A-Z]", var.lower_str)) == 0
    error_message = "В царство карликов принимаются только маленькие буквы. Вам в следующее окошко."
  }
}

variable "choose_the_right_pill" {
  type = object({ blue: bool, red:  bool })
  default = {blue: true, red:  false }

  validation {
    condition = values(var.choose_the_right_pill)[0] == !values(var.choose_the_right_pill)[1]
    error_message = "Джедай, ты в матрице! Ты должен выбрать только одну таблетку - выбирай настоящее или илллюзия?"
  }
}
```
</details>

![](./assets/5-1.png)

## Задание 6*

## Задание 7*

[Модуль с инфраструктурой для remote state](./modules/remote_state_infra/main.tf) включает в себя:

* создание сервисного аккаунта
* добавление роли `storage.editor` созданному сервисному аккаунту
* создание статического доступа ключей
* собственно, создание самого бакета.

[Применение модуля `remote state` в рандомном проекте с ВМ-ами, например.](./src/main.tf)
.
Процесс применения модуля в каком-либо проекте:

1. `Apply` модуля `remote state` отдельно, сохраняю креды в env переменных:

```
export ACCESS_KEY="..."
export SECRET_KEY="..."
```

2. Иду в папку с проектом `src`, запускаю его командой:

```bash
terraform init -backend-config="access_key=$ACCESS_KEY" -backend-config="secret_key=$SECRET_KEY" -migrate-state
```

![](./assets/7-1.png)
![](./assets/7-2.png)
![](./assets/7-3.png)

