.PHONY: help format lint validate validate-kube validate-yaml test clean \
        kind-up kind-down build load build-gateway load-gateway ingress secrets linkerd \
        deploy-baseline deploy-secure \
        pull-model-baseline pull-model-secure pause-baseline pause-secure \
        resume-baseline resume-secure deploy verify measure measure-load

IMAGE ?= llm-api:1.0.0
GATEWAY_IMAGE ?= llm-gateway:1.0.0
CLUSTER ?= thesis-cluster

help:
	@echo "Code quality:   format lint test validate"
	@echo "Cluster:        kind-up kind-down"
	@echo "Image:          build load build-gateway load-gateway"
	@echo "Secure setup:   secrets ingress (once), then deploy-secure"
	@echo "Deploy:         deploy-baseline deploy-secure"
	@echo "Model:          pull-model-baseline pull-model-secure"
	@echo "Run one env at a time: pause-<env> / resume-<env>"

format:
	ruff format apps
	ruff check --fix apps

lint:
	ruff check apps

validate-yaml:
	yamllint .

validate-kube:
	kubectl kustomize kubernetes/overlays/kind-baseline | kubeconform -strict -summary
	kubectl kustomize kubernetes/overlays/kind-secure | kubeconform -strict -summary

validate:
	make lint
	make validate-yaml
	make validate-kube

test:
	cd apps/llm-api && pytest
	cd apps/llm-gateway && pytest

kind-up:
	./scripts/kind-up.sh

kind-down:
	kind delete cluster --name $(CLUSTER)

build:
	docker build -t $(IMAGE) apps/llm-api

load:
	kind load docker-image $(IMAGE) --name $(CLUSTER)

build-gateway:
	docker build -t $(GATEWAY_IMAGE) apps/llm-gateway

load-gateway:
	kind load docker-image $(GATEWAY_IMAGE) --name $(CLUSTER)

ingress:
	./scripts/install-ingress.sh

secrets:
	./scripts/gen-secrets.sh

linkerd:
	./scripts/install-linkerd.sh

deploy-baseline:
	kubectl apply -k kubernetes/overlays/kind-baseline

deploy-secure:
	kubectl apply -k kubernetes/overlays/kind-secure

pull-model-baseline:
	./scripts/pull-model.sh llm-baseline

pull-model-secure:
	./scripts/pull-model.sh llm-secure kubernetes/overlays/kind-secure

pause-baseline:
	./scripts/pause-env.sh llm-baseline

pause-secure:
	./scripts/pause-env.sh llm-secure

resume-baseline:
	./scripts/resume-env.sh kubernetes/overlays/kind-baseline llm-baseline

resume-secure:
	./scripts/resume-env.sh kubernetes/overlays/kind-secure llm-secure

# Generic helpers: make deploy ENV=kind-c1-rbac | make verify NS=llm-c1-rbac
deploy:
	kubectl apply -k kubernetes/overlays/$(ENV)

verify:
	./scripts/verify-controls.sh $(NS)

# make measure CONFIG=c1-rbac REP=1
measure:
	./scripts/measure-config.sh $(CONFIG) $(REP)

# make measure-load CONFIG=c6-all REP=1 [PATHS=health]
measure-load:
	./scripts/measure-load.sh $(CONFIG) $(REP)

clean:
	find . -type d -name "__pycache__" -prune -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
