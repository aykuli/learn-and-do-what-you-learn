# [Домашнее задание к занятию 11 «Teamcity»](https://github.com/netology-code/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/README.md)

## Подготовка к выполнению

* Создание виртуальных машин через terraform на основе образа из библиотеки Яндекса `container-optimized-image`

    * [проект в папке tf](./tf/main.tf)
    * там же создаются docker `compose.yml` файлы с помощью `cloud-init` файла, через образы от `jetbrains`
      * [agent-cloud-init.tftpl](./tf/agent-cloud-init.tftpl)
      * [server-cloud-init.tftpl](./tf/server-cloud-init.tftpl)

Получилось:

![](./assets/00.png)

* Teamcity server with authorized agent

![](./assets/01.png)

* Запустила playbook

  * склонировала указанную репу через: `git sparse-checkout set <PATH_TO_FOLDER_IN_REPOSITORY>`
  * указала ip созданный машины для `nexus` в [hosts.yml](./playbook/infrastructure/inventory/cicd/hosts.yml)
  * не с первого, но с раза запустила плейбук с установкой nexus-а и его конфигурационных файлов

![](./assets/1.png)
![](./assets/2.png)

## Основная часть

1. Создайте новый проект в `teamcity` на основе `fork`.
2. Сделайте autodetect конфигурации.
3. Сохраните необходимые шаги, запустите первую сборку `master`.

![](./assets/4.png)
![](./assets/5.png)
![](./assets/6.png)
![](./assets/7.png)

4. Поменяйте условия сборки: если сборка по ветке `master`, то должен происходит mvn `clean deploy`, иначе mvn `clean test`.

![](./assets/71.png)

5. Для `deploy` будет необходимо загрузить `settings.xml` в набор конфигураций `maven` у `teamcity`, предварительно записав туда креды для подключения к `nexus`.

![](./assets/50.png)
![](./assets/70.png)

Пользователь в `nexus` для деплоя релизов с `teamcity-server`

![](./assets/72.png)

6. В `pom.xml` необходимо поменять ссылки на репозиторий и `nexus`. ✅ 

7. Запустите сборку по `master`, убедитесь, что всё прошло успешно и артефакт появился в `nexus`.

![](./assets/8.png)
![](./assets/81.png)
![](./assets/82.png)

9. Создайте отдельную ветку feature/`add_reply` в репозитории.

10. Напишите новый метод для класса `Welcomer`: [метод]() должен возвращать произвольную реплику, содержащую слово `hunter`.

  * [метод pray()](https://github.com/aykuli/example-teamcity/blob/master/src/main/java/plaindoll/Welcomer.java#L18)

11. Дополните тест для нового метода на поиск слова `hunter` в новой реплике.

  *  [test method welcomerSaysHunter()](https://github.com/aykuli/example-teamcity/blob/master/src/test/java/plaindoll/WelcomerTest.java#L26)
  *  [test method welcomerPray()](https://github.com/aykuli/example-teamcity/blob/master/src/test/java/plaindoll/WelcomerTest.java#L38)

12. Сделайте `push` всех изменений в новую ветку репозитория.

![](./assets/9.png)

13. Убедитесь, что сборка самостоятельно запустилась, тесты прошли успешно.


Для самостоятельного запуска я добавила триггер на ветки `не` мастер которые. Затестила с новой веткой - работает.

![](./assets/18.png)

![](./assets/10.png)


14. Внесите изменения из произвольной ветки `add_reply` в `master` через Merge.

![](./assets/14.png)

15. Проведите повторную сборку мастера, убедитесь, что сбора прошла успешно и артефакты собраны.

![](./assets/16.png)
![](./assets/17.png)

![](./assets/15.png)

