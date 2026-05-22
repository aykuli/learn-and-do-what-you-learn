# [Домашнее задание к занятию 6 «Создание собственных модулей»](https://github.com/netology-code/mnt-homeworks/tree/MNT-video/08-ansible-06-module)

<details>
<summary>prep</summary>

![](./assets/prep.png)
сохраню для себя:
1. `git clone git@github.com:ansible/ansible.git`
2. `cd ansible.`
3. Создайте виртуальное окружение: `python3 -m venv venv`.
4. Активируйте виртуальное окружение: `. venv/bin/activate`. Дальнейшие действия производятся только в виртуальном окружении.
5. Установите зависимости `pip install -r requirements.txt`.
6. Запустите настройку окружения `. hacking/env-setup`.
7. Если все шаги прошли успешно — выйдите из виртуального окружения `deactivate`.
8. Ваше окружение настроено. Чтобы запустить его, нужно находиться в директории `ansible` и выполнить конструкцию `. venv/bin/activate && . hacking/env-setup.`

</details>

Первый успешный запуск модуля локально. 

![](./assets/0.png)

## Моя коллекция aykuli.yandex_cloud_elk

Mоя коллекция `aykuli.yandex_cloud_elk` содержит 2 модуля:


* [модуль создания виртуальных машин](https://github.com/aykuli/aykuli.yandex_cloud_elk/blob/master/plugins/modules/vms.py)

Создания ВМ происходит за счёт вызова уже установленного у пользователя консольной утилиты от ЯО `yc cli` с помощью python модуля `subprocess` в виде:

```python
subprocess.run([
      "yc", "compute", "instance", "create",
      "--name", name,
      "--platform", params["platform"],
      "--zone", params["zone"],
      "--cores", params["cores"],
      "--memory", params["memory"],
      "--preemptible", params["preemptible"],
      "--core-fraction", params["core_fraction"],
      "--network-interface", f"subnet-id={subnet_id},nat-ip-version=ipv4",
      "--create-boot-disk", f"image-family={params["image_family"]},image-folder-id=standard-images,size={params["disk_size"]}",
      "--metadata", f"ssh-keys={params["user"]}:{ssh_pub_key}",
      "--format", "json"
    ], capture_output=True)
```

либо

```python
subprocess.getoutput(f"yc vpc subnet get {params["subnet_name"]} --format json")
```

Модуль создаёт ВМ либо с дефолтными параметрами, либо, если предоставить, с нужными параметрами и на выходе отдаёт в виде готово `yaml` контента json с названием машин и `ip` адресами. Реализация может быть разной в принципе - зависит от задачи. Тут уж как я решила, так и сделала.


* [модуль создания файла на указанном хосте](https://github.com/aykuli/aykuli.yandex_cloud_elk/blob/master/plugins/modules/fcreate.py)

Я решила положить модуль создания файла в ту же [коллекцию](https://github.com/aykuli/aykuli.yandex_cloud_elk).

Модуль проверяет наличие файла, проверяет контент, и в зависимости от этих условии создаёт/переписывает файл и выдаёт ответ.

Этот модуль я в примере плейбука использовала для создания инвентори файла с контентом-результатом вывода предыдущего описанного модуля:

![](./playbook/play.yml)

## Playbook

Сам плейбук представлен в папке [`playbook`](./playbook/). Сценарии, которые выполняет плейбук:

* Создаёт виртуальные машины, выдаёт информацию о созданных машинах
* Создаёт файл инвентаризации, записывает туда информцию о хостах, куда будут устанавливаться ноды инфраструктуры.
* Создаются `clickhouse` - хранитель логов, `vector`- менеджер логов и `lighthouse` - визуальный интерфейс для просмотра этих логов, и настраиваются для общения меж собой, как и в предыдущих задачах - тут ничего не изменилось с предыдущих задач.

