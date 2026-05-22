Log Management Pipeline (Lighthouse, ClickHouse, Vector)
=========
Этот проект автоматизирует развертывание системы сбора и визуализации логов.

Roles
--------------
* [vector-role](https://github.com/aykuli/vector-role)
* [lighthouse-role](https://github.com/aykuli/lighthouse-role)
* [ansible-clickhouse](https://github.com/AlexeySetevoi/ansible-clickhouse)



Архитектура
--------------
* **aykuli.yandex_cloud_elk.vms**: Создаёт виртуальные машины и на выходе отдаёт ip адреса и названия хостов
* **fcreate**: Создаёт из сообщения предыдущего модуля файл инвентиризации для пследующих сценариев
* **Vector**: Собирает системные логи (journald) и отправляет их в ClickHouse.
* **ClickHouse**: Высокопроизводительная БД для хранения логов.
* **Lighthouse**: Веб-интерфейс для выполнения SQL-запросов к ClickHouse.

Что происходит:

- на 3 сервера устанавливаются Vector, ClickHouse и Lighthouse, и сразу настраиаются.
- в кликхаусе сразу устанавливается база данных и таблица для логов.
- Систему сразу должна запуститься и должна происходить запись логов из вектора в кликхауса.
- Доступ к данным в интерфейсе лайтхауса аторизированный.

Требования
--------------

* Установленный Ansible.
* 3 виртуальные машины

Быстрый старт
--------------

1. Загрузите нужные роли:

```bash
ansible-playbook -i inventory/prod.yml play.yml 
```

В папке `inventory` появился файл `prod.yml` должны быть уже 3 хоста.

2. Запуск `ansible-playbook`

```bash

ansible-playbook -i inventory/prod.yml play.yml
```

Как пользоваться системой
--------------

#### Доступ к UI

Откройте в браузере IP машины Lighthouse.
Если данные не подтянулись автоматически, введите в настройках подключения IP сервера ClickHouse и порт 8123.

Если всё прошло успешно, вы можете видеть логи в браузере по адресу:

    http://<LIGHTHOUSE-IP>/#http://<CLICKHOUSE-IP>:8123/?user=<my-user>&password=<my-pswrd>

что-то похожее на это:
![](../assets/lighthouse.png)

### Проверка данных в ClickHouse
Зайдите на сервер ClickHouse и проверьте поступление логов:

```
clickhouse-client -q "SELECT count() FROM logs.applogs"
```


Лицензия
-------

BSD

Автор
------------------

Aynur Shauerman