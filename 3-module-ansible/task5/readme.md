# [Домашнее задание к занятию 5 «Тестирование roles»](https://github.com/netology-code/mnt-homeworks/blob/MNT-video/08-ansible-05-testing/README.md)

## Molecule

### vector-role testing with molecule

Видимо задача устарела. Создание папки тестирования для `molecule` было командой для сценария:

```bash
molecule init scenario <scenario-name>
```

Много было запинаний с каждым из семейств `linux`, для которых я писала тесты, `vector role` потребовал рефакторинга в связи с:
* разными ссылками для скачивания пакетов для `vector` для разных дистрибутивов линукса
* использованием мока для `Clickhouse` во время теста - писаал условный оператор в шаблоне конфига `vector`
* дописала некоторые моменты (типа метаинформации). Почему-то `molecule` не хотел запускать тест без них.
* Вынесла в переменные некотрые креды, которые в прошлый раз упустила из внимания.


#### `ubuntu_jammy`

```bash
molecule init scenario ubuntu_jammy
```

![](./assets/0_molecule_ubuntu_jammy_for_vector_init.png)



![](./assets/debian/0.png)
![](./assets/debian/1.png)
![](./assets/debian/2.png)
![](./assets/debian/3.png)
![](./assets/debian/4.png)
![](./assets/debian/5.png)

#### `rockylinux`:

![](./assets/redhat/0.png)
![](./assets/redhat/1.png)
![](./assets/redhat/2.png)
![](./assets/redhat/3.png)
![](./assets/redhat/4.png)

## Tox

Я изменила [`tox.ini`](https://github.com/aykuli/vector-role/blob/master/tox.ini) под своё окружение. Указанным в домашнем задании контейнером не стала пользоаться, мне не нравится там наличие слов `--privileged=True`. Взяла более новые версии `python` и `ansible`.

Результат выполнения:

```bash
py310-ansible215: OK (60.45=setup[12.09]+cmd[48.37] seconds)
py313-ansible220: OK (37.81=setup[9.84]+cmd[27.98] seconds)
congratulations :) (98.29 seconds)
```

![](./assets/tox/0.png)
![](./assets/tox/1.png)
![](./assets/tox/2.png)
![](./assets/tox/3.png)
![](./assets/tox/4.png)
![](./assets/tox/5.png)
![](./assets/tox/6.png)
![](./assets/tox/7.png)
![](./assets/tox/8.png)
![](./assets/tox/9.png)
![](./assets/tox/10.png)
![](./assets/tox/11.png)




