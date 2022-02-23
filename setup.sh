#!/usr/bin/env bash

OK=0
KO=1

# redefine pushd/popd
# see: https://stackoverflow.com/questions/25288194/dont-display-pushd-popd-stack-across-several-bash-scripts-quiet-pushd-popd
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

# usage helper
function help {
    echo "$0 OPTIONS [ANSIBLE ARGUMENTS]"
    echo
    echo "OPTIONS:"
    echo "   [--local]"
}

# parse options
# see https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --local)
            LOCAL=$OK
            shift # past argument
            ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
    esac
done

# verify requirements
requirements=(ansible-playbook git)
for r in "${requirements[@]}"; do
    if ! r_path=$(type -p "$r"); then
        echo "$r_path executable not found in path, aborting"
        exit $KO
    fi
done

# perform local role install
ansible -b -m package -a "name=libvirt-dev" localhost > /dev/null

# install requirements
if [ -f roles/requirements.yml ] ; then
    ansible-galaxy install -r roles/requirements.yml --force
fi
if [ -f collections/requirements.yml ] ; then
    ansible-galaxy collection install -r collections/requirements.yml --force
fi

# purge temp files
exit $OK
