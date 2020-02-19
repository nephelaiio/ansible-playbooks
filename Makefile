inventories := $(shell find ./inventory -mindepth 1 -maxdepth 1 -type d -printf "%f\n")
decrypt := $(addsuffix _decrypt, $(inventories))
key := $(addsuffix _key, $(inventories))
rekey := $(addsuffix _rekey, $(inventories))

setup:
	ansible-playbook setup.yml

$(decrypt): load_vaults
	bin/decrypt_directory.sh --directory inventory/$(patsubst %_decrypt,%,$@) --debug

$(key): load_vaults
	bin/rekey_directory.sh --vault-id inventory/$(patsubst %_key,%,$@) --debug

$(rekey): load_vaults
	bin/rekey_directory.sh --vault-id inventory/$(patsubst %_rekey,%,$@) --rekey --debug

load_vaults:
	bin/load_vaults.sh
