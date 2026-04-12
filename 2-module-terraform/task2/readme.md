# [Домашнее задание к занятию «Основы Terraform. Yandex Cloud»](https://github.com/netology-code/ter-homeworks/blob/main/02/hw-02.md)

## Задание 1

![](./assets/1-1.png)
![](./assets/1-2.png)

Создала новый ключ и сохранила.
![](./assets/1-3.png)

4. Запускаю проект
![](./assets/1-4.png)

Были ошибки:
* с корреляцией версий терраформа локально и указанной версии в проекте 
* не добавила достаточной роли для сервисного аккаунта, чтобы создавать сеть и подсети
* создаваемая сеть необходима, чтобы была доступна в рамках рабочей папки

* версия провайдера не была указана
* Платформа v4 недоступна в зоне ru-central1-a, доступны v1, v2, v3:
```shell
Availability Zone	Platform ID	CPU Architecture	Notes
ru-central1-a	standard-v1, standard-v2, standard-v3	Intel Broadwell, Cascade Lake, Ice Lake	Most versatile zone.
ru-central1-b	standard-v1, standard-v2, standard-v3	Intel Broadwell, Cascade Lake, Ice Lake	High availability backup for -a.
ru-central1-c	standard-v2	Intel Cascade Lake	Limited platform support (No v1 or v3 in some regions).
ru-central1-d	standard-v3	Intel Ice Lake	Newest zone, focuses on high-performance v3.
```

* да емаё, ещё и опечатка в слове стандарт, как по русски
* была несогласованность в уровне производительности с платформой. [Посмoтрела здесь](https://yandex.cloud/ru/docs/compute/concepts/performance-levels) и перевыбрала платформу standard-v1 и количество vCPU = 2.

и наконец получилось:
![](./assets/1-7.png)

5. Подключение через ssh:
![](./assets/1-8.png)

6. Параметры `preemptible = true` и `core_fraction=5` в учёбе нужны для экономии средств на учебнос счету. Так как пока мы тренируемся только создавать/удалять ВМ, а не нагружать.

## Задание 2

1. Использование перменных

![](./assets/2-1.png)

## Задание 3

![](./assets/3-1.png)
![](./assets/3-2.png)
![](./assets/3-3.png)
![](./assets/3-4.png)

## Задание 4

[output.tf](./src/outputs.tf)

![](./assets/4-1.png)

## Задание 5

![](./assets/5-1.png)

## Задание 6

![](./assets/6-1.png)

## Задание 7*

![](./assets/7-1.png)

<details><summary>log</summary>

```bash
$ terraform console 
> local.test_list[1]
"staging"
> length(local.test_list)
3
> local.test_map.admin
"John"
> "${local.test_map.admin} is ${sort(keys(local.test_map)).0} for ${sort(keys(local.servers)).1} server based on OS ${local.servers[sort(keys(local.servers)).1].image} with ${local.servers[sort(keys(local.servers)).1].cpu} vcpu, ${local.servers[sort(keys(local.servers)).1].ram} ram and ${length(local.servers[sort(keys(local.servers)).1].disks)} virtual disks"
"John is admin for production server based on OS ubuntu-20-04 with 10 vcpu, 40 ram and 4 virtual disks"
```
</details>

## Задание 8*

![](./assets/8-1.png)

<details><summary>log</summary>

```bash
$ terraform console 
> sort(merge(var.test...).dev1).1
"ssh -o 'StrictHostKeyChecking=no' ubuntu@62.84.124.117"
```
</details>

## Задание 9*

Сделала пароль пользователя в ВМ.

NAT-шлюз настроила - оутпут что-то не то показывает после `terraform apply`.

![](./assets/9-1.png)

В веб-консоли ЯО нет публичного адреса у ВМ:

![](./assets/9-2.png)

И через `cli` инструмент нет публичного адреса у ВМ и ссш доступа нет, висит запрос долго, а потом выходит с таймаутом.
![](./assets/9-3.png)

Зашла через последовательный порт: Доступ наружу есть! Пингуются разные ресурсы:
![](./assets/9-4.png)





