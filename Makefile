### Apply
.PHONY: apply-s3
apply-s3:
	terraform apply -target=module.s3 -auto-approve

.PHONY: apply-all
apply-all:
	terraform apply -auto-approve

.PHONY: apply
apply: apply-s3 apply-all

### Destroy
.PHONY: destroy-s3
destroy-s3:
	terraform destroy -target=module.s3 -auto-approve

.PHONY: destroy-all
destroy-all:
	terraform destroy -auto-approve

.PHONY: destroy
destroy: destroy-s3 destroy-all
