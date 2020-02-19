setup:
	ansible-playbook setup.yml

rekey_home:
	bin/rekey_directory.sh home

rekey_common:
	bin/rekey_directory.sh common

load_vaults:
	bin/load_vaults.sh
