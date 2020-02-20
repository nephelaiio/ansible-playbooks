inventories := $(shell find ./inventory -mindepth 1 -maxdepth 1 -type d -printf "%f\n")
decrypt := $(addsuffix _decrypt, $(inventories))
key := $(addsuffix _key, $(inventories))
rekey := $(addsuffix _rekey, $(inventories))

setup:
	ansible-playbook setup.yml

$(decrypt): load_vaults
	bin/decrypt --directory inventory/$(patsubst %_decrypt,%,$@)

$(key): load_vaults
	bin/rekey --vault-id $(patsubst %_key,%,$@)

$(rekey): load_vaults
	bin/rekey --vault-id $(patsubst %_rekey,%,$@)

load_vaults:
	bin/env
