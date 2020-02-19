setup:
	ansible-playbook setup.yml

home_decrypt:
	bin/decrypt_directory.sh inventory/home

home_key:
	bin/rekey_directory.sh --vault-id home

home_rekey:
	bin/rekey_directory.sh --vault-id home --rekey

common_decrypt:
	bin/decrypt_directory.sh inventory/common

common_key:
	bin/rekey_directory.sh --vault-id home

common_rekey:
	bin/rekey_directory.sh --vaut-id common --rekey

load_vaults:
	bin/load_vaults.sh
