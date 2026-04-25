# Итоговый проект модуля «Облачная инфраструктура. Terraform»

## Задание 1. Развертывание инфраструктуры в Yandex Cloud

* Создание Virtual Private Cloud (VPC)

Вот такая схема нарисовала с `Terraform Graph` расширением `VSCode`:

![](./assets/0.png)

В первый раз получилось поднять систему (режистри был ещё впереди):
![](./assets/1.png)


Создайте подсети.
Создайте виртуальные машины (VM):

    Настройте группы безопасности (порты 22, 80, 443).
    Привяжите группу безопасности к VM.

Опишите создание БД MySQL в Yandex Cloud.
Опишите создание Container Registry.

Я испытывала трудности с понимаеием сетей, сидра
последовательностью создаваемых ресурсов
Я перепутала в dynamic переменные ingress/egress и страдала из-за этого.

```bash
# Проверка самого файла на ошибки форматирования
cloud-init schema --config-file cloud-init.yml
```


### Источники
* [ЯО VPC понимается сеть ...](https://habr.com/ru/companies/yandex/articles/487694/)
* [Cетевые сервисы](https://yandex.cloud/ru/docs/vpc/concepts/)
* [Сертификат от Let's Encrypt](https://yandex.cloud/ru/docs/certificate-manager/concepts/managed-certificate)