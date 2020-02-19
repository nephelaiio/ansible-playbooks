setup:
	ansible-playbook setup.yml

key_home:
	bin/rekey_directory.sh home

rekey_home:
	bin/rekey_directory.sh home --rekey

key_common:
	bin/rekey_directory.sh home

rekey_common:
	bin/rekey_directory.sh common --rekey

load_vaults:
	bin/load_vaults.sh
