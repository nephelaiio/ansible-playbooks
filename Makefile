setup:
	ansible-playbook setup.yml

decrypt_home:
	bin/decrypt_directory.sh inventory/home

key_home:
	bin/rekey_directory.sh --vault-id home

rekey_home:
	bin/rekey_directory.sh --vault-id home --rekey

decrypt_comon:
	bin/decrypt_directory.sh inventory/common

key_common:
	bin/rekey_directory.sh --vault-id home

rekey_common:
	bin/rekey_directory.sh --vaut-id common --rekey

load_vaults:
	bin/load_vaults.sh
