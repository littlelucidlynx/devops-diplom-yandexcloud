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

```yaml
terraform init
terraform apply -auto-approve
```

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/01_bucket_init_apply.png)

После создания бакета в папку `02_infrastructure` экспортируются файлы `backend.auto.tfvars` и `personal.auto.tfvars` с данными для бакета и подключения к ЯО. Файлы добавлены в `.gitignore`. Согласен, очень кривой вариант, в будущем можно попробовать использовать **vault**

Инициализация терраформа и формирование инфраструктуры
```yaml
terraform init -backend-config=backend.auto.tfvars -reconfigure
terraform apply -auto-approve
```

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/02_infrastructure_init.png)

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/02_infrastructure_apply.png)

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/yc_services.png)

State основной инфраструктуры хранится в бакете Yandex Cloud

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/tfstate_in_bucket.png)

---
### Создание Kubernetes кластера

Для развертывания Kubernetes кластера воспользуюсь готовым решением [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes) из мастера и нод групп. Данный вариант выбран из-за стабильности и скорости развертывания, что очень полезно при большом количестве тестовых работ в условиях экономии ресурсов

Предварительно самостоятельно забэкапил файл `~/.kube/config`, поскольку буду писать его терраформом напрямую в пользовательскую папку. В проде так делать плохо, но в рамках дипломной работы считаю допустимым

В файле `~/.kube/config` находятся данные для доступа к кластеру

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/cat_kubeconfig.png)

Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/kubectl_get_pods.png)

---
### Создание тестового приложения

Создан отдельный репозиторий [nginx-static-app](https://github.com/littlelucidlynx/nginx-static-app). Приложение представляет собой статический сайт на nginx, создаваемый из `Dockerfile` на основе `nginx:alpine`

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/docker_build_push_run.png)

Для теста развернут локально

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/docker_run_local.png)

Образ выложен на DockerHub с тегом `init`

[Ссылка](https://hub.docker.com/r/littlelucidlynx/static-nginx-app/tags)

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/dockerhub_image_init.png)

---
### Подготовка cистемы мониторинга и деплой приложения

Создание пространства имен для проекта
```yaml
kubectl create namespace myproject
```

Helm-чарт для мониторинга
```yaml
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && \
helm repo update && \
helm install prometheus prometheus-community/kube-prometheus-stack --namespace=myproject
```

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/ns_prometheus.png)

Helm-чарт для ингресса
```yaml
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
helm repo update && \
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace=myproject
```

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/ingress.png)

Деплой приложения из образа `littlelucidlynx/static-nginx-app:init`, деплой сущности ингресс и создание сервисной учетной записи для CI/CD GitHub Actions
```yaml
kubectl apply -f deploy.yml
kubectl apply -f ingress.yml
kubectl apply -f sa_for_github.yml
```

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/deploy_ingress_sa.png)

Поправлю DNS, создам A-записи для домена, приложения и мониторинга, привяжу их к IP балансировщика

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/dns_records.png)

Поскольку диплом далек от идеала, то приложение доступно по 80 порту по адресу: http://app.littlelucidlynx.ru

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/app_80.png)

Grafana (admin/prom-operator) доступна по адресу: http://grafana.littlelucidlynx.ru

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/grafana_80.png)

---
### Установка и настройка CI/CD

Для организации CI/CD воспользуюсь `GitHub Actions`. Репозитории диплома размещены на гитхабе, отдельные контейнеры и виртуальные машины с CI/CD и воркерами разворачивать не надо, что экономит средства. В проектах же с высокими требованиями к безопасности и в закрытых контурах есть смысл разворачивать self-hosted CI/CD систему.

Для взаимодействия пайплайна с кластером необходимо сгенерировать конфиг-файл для сервисного аккаунта, созданного ранее, и передать его в секреты GitHub Actions. Для взаимодействия пайплайна с репозиторием необходимо передать учетные данные отдельно созданного токена (DOCKERHUB_USERNAME и DOCKERHUB_TOKEN) в секреты GitHub Actions.

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/actions_secrets.png)

Логика пайплайна такова:
- Если в ветке main происходит коммит **БЕЗ УКАЗАНИЯ ТЕГА** (в `refs/tags/` пусто), то артефакт отправляется в DockerHub с тегом формата `nightly-%d-%m-%Y-%H-%M-%S`. Так же в индексном файле заменяется строка BUILD на получившийся тег

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/commit_push_no_tag.png)

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/actions_pipeline_no_tag.png)

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/dockerhub_nightly.png)

- Если в ветке main происходит коммит **С УКАЗАНИЕМ ТЕГА** (в `refs/tags/` не пусто), то артефакт отправляется в DockerHub с указанным тегом, в индексном файле заменяется строка BUILD на получившийся тег, происходит деплой образа в кластер Kubernetes

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/tag_push_0.0.1.png)

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/actions_pipeline_tag_0.0.1.png)

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/dockerhub_tag_0.0.1.png)

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/app_0.0.1.png)

Несколько коммитов и тегов спустя

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/tag_push_0.1.5.png)

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/actions_pipeline_tag_0.1.5.png)

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/dockerhub_tag_0.1.5.png)

![Image alt](https://github.com/littlelucidlynx/devops-diplom-yandexcloud/blob/main/Screen/app_0.1.5.png)