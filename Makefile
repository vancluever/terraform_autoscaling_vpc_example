.PHONY: tf-modules infrastructure
TF_DIR ?= terraform
TF_CMD ?= apply
export AWS_DEFAULT_REGION ?= us-west-2

tf-modules:
	terraform get -update=true $(TF_DIR)

infrastructure: tf-modules
	terraform $(TF_CMD) $(TF_DIR)
