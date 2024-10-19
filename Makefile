TF_REPO := "https://github.com/tfutils/tfenv.git"
TF_ENV_PATH := "$(HOME)/.tfenv"
TF_VERSION := $(file < .terraform_version)
TF_PATH := $(TF_ENV_PATH)/versions/$(TF_VERSION)
TF_ENV := $(TF_ENV_PATH)/bin/tfenv
TERRAFORM := $(TF_PATH)/terraform

usage:
	@echo "Setup: Install tfenv"
	@echo "Install: Install tf version"
	@echo "Uninstall: Uninstall tf version"
	@echo "Init: Terraform init"
	@echo "Plan: Terraform plan"
	@echo "Apply: Terraform apply"
	@echo "Destroy: Terraform destroy"

# auth:
# 	curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
# 	tar -xf google-cloud-cli-linux-x86_64.tar.gz
# 	./google-cloud-sdk/install.sh
# 	./google-cloud-sdk/bin/gcloud init
# 	./google-cloud-sdk/bin/gcloud auth

setup:
	@if [ ! -d $(TF_ENV_PATH) ]; then \
		git clone --depth=1 $(TF_REPO) ~/.tfenv; \
	fi

install: setup
	@$(TF_ENV) install $(TF_VERSION) && $(TF_ENV) use $(TF_VERSION)

uninstall:
	@$(TF_ENV) uninstall $(TF_VERSION)

init: install
	$(TERRAFORM) init

plan: init format
	@$(TERRAFORM) plan

apply: plan
	@$(TERRAFORM) apply

destroy: init
	@$(TERRAFORM) destroy

format:
	@$(TERRAFORM) fmt -recursive