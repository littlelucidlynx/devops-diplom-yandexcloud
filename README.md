# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Основной [репозиторий](https://github.com/littlelucidlynx/devops-diplom-yandexcloud)

Репозиторий с инфраструктурой разделен на папки:
[01_bucket](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/tree/main/01_bucket) - отвечает за создание сервисной учетной записи и бакета в Yandex Cloud
[02_infrastructure](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/tree/main/02_infrastructure) - отвечает за развертывание инфраструктуры и поднятие кластера Kubernetes
[03_app](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/tree/main/03_app) - отвечает за развертывание приложения в кластер и сущности ингресс

Дополнительно в корне репозитория подготовлены скрипты `init.sh` и `stop.sh` для последовательного запуска команд и уничтожения инфраструктуры

После создания бакета в папку `02_infrastructure` экспортируются файлы `backend.auto.tfvars` и `personal.auto.tfvars` с данными для бакета и подключения к ЯО. Файлы добавлены в `.gitignore`. Согласен, очень кривой вариант, в будущем можно попробовать использовать **vault**

State основной инфраструктуры хранится в бакете Yandex Cloud

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Для развертывания Kubernetes кластера воспользуюсь готовым решением [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes) из мастера и нод групп. Данный вариант выбран из-за стабильности и скорости развертывания, что очень полезно при большом количестве тестовых работ в условиях экономии ресурсов.

Предварительно самостоятельно забэкапил файл `~/.kube/config`, поскольку буду писать его терраформом напрямую в пользовательскую папку. В проде так делать плохо, но в рамках дипломной работы считаю допустимым

Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

Создан отдельный репозиторий [nginx-static-app](https://github.com/littlelucidlynx/nginx-static-app). Приложение представляет собой статический сайт на nginx, создаваемый из `Dockerfile` на основе `nginx:alpine`

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/docker_build_push_run.png)

Для теста развернут локально

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/docker_run_local.png)

Образ выложен на DockerHub с тегом `init`

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/dockerhub_image_init.png)

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Создание пространства имен для проекта
```yaml
kubectl create namespace myproject
```

Helm-чарт для ингресса
```yaml
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
helm repo update && \
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace=myproject
```

Helm-чарт для мониторинга
```yaml
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && \
helm repo update && \
helm install prometheus prometheus-community/kube-prometheus-stack --namespace=myproject
```

Деплой приложения из образа `littlelucidlynx/static-nginx-app:init`, деплой сущности ингресс и создание сервисной учетной записи для CI/CD GitHub Actions
```yaml
kubectl apply -f deploy.yml
kubectl apply -f ingress.yml
kubectl apply -f sa_for_github.yml
```

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.
5. Atlantis или terraform cloud или ci/cd-terraform
---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

Для организации CI/CD воспользуюсь `GitHub Actions`. Репозитории диплома размещены на гитхабе, отдельные контейнеры и виртуальные машины с CI/CD и воркерами разворачивать не надо, что экономит средства. В проектах же с высокими требованиями к безопасности и в закрытых контурах есть смысл разворачивать self-hosted CI/CD систему.

Для взаимодействия пайплайна с кластером необходимо сгенерировать конфиг-файл для сервисного аккаунта, созданного ранее, и передать его в секреты GitHub Actions. Для взаимодействия пайплайна с репозиторием необходимо передать учетные данные отдельно созданного токена (DOCKERHUB_USERNAME и DOCKERHUB_TOKEN) в секреты GitHub Actions.

Логика пайплайна такова:
- Если в ветке main происходит коммит **БЕЗ УКАЗАНИЯ ТЕГА** (в `refs/tags/` пусто), то артефакт отправляется в DockerHub с тегом формата `nightly-%d-%m-%Y-%H-%M-%S`. Так же в индексном файле заменяется строка BUILD на получившийся тег
- Если в ветке main происходит коммит **С УКАЗАНИЕМ ТЕГА** (в `refs/tags/` не пусто), то артефакт отправляется в DockerHub с указанным тегом, в индексном файле заменяется строка BUILD на получившийся тег, происходит деплой образа в кластер Kubernetes

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

