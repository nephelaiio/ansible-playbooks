inventories := $(shell find ./inventory -mindepth 1 -maxdepth 1 -type d | xargs -L 1 basename)
decrypt := $(addsuffix _decrypt, $(inventories))
key := $(addsuffix _key, $(inventories))
rekey := $(addsuffix _rekey, $(inventories))

setup:
	ansible-playbook setup.yml

$(decrypt):
	bin/decrypt_directory.sh --directory inventory/$(patsubst %_decrypt,%,$@)

$(key):
	bin/rekey_directory.sh --vault-id inventory/$(patsubst %_key,%,$@)

$(rekey):
	bin/rekey_directory.sh --vault-id inventory/$(patsubst %_rekey,%,$@) --rekey

load_vaults:
	bin/load_vaults.sh
