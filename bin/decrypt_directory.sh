#!/usr/bin/env bash

# global definitions
KO=1
OK=0
TRUE=0
FALSE=1

function help {
    echo "$0 OPTIONS <playbook> [ <playbook> ... ]"
    echo
    echo "OPTIONS:"
    echo "   --vault-id   <vault>  # vault-id for key/rekey"
    echo "  [--vault-dir] <dir>    # vault password file location"
    echo "  [--generate]           # generate new vault password"
    echo "  [--verify]             # restrict rekey to matching vault-ids"
    echo "  [--debug]"
}

function debug {
    if [ "${DEBUG}" -eq "${TRUE}" ]; then
        echo "$@"
    fi
}

function check_requirement {
    cmd=$1
    command -v "${cmd}" >/dev/null 2>&1 || {
        echo "${cmd} not found, aborting"
        exit "${ERROR}"
    }
}

check_requirement ansible-vault

# parse options (https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash)
POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --directory)
            DECRYPT_DIR="$2"
            shift # past argument
            shift # past value
            ;;
        --help)
            help
            exit ${SUCCESS}
            ;;
        --debug)
            DEBUG=${TRUE}
            AWXCLI_VERBOSE="--verbose"
            shift # past argument
            ;;
        *)  # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# validate options
if [ -z "${DECRYPT_DIR}" ]; then
    echo "--directory <path> option is required"
    exit ${KO}
fi
if [ ${#POSITIONAL[@]} -gt 0 ]; then
    echo "Unknown positional arguments ${POSITIONAL[@]}"
    exit ${KO}
fi

# set derived files
DECRYPT_FILES=$(find "${DECRYPT_DIR}" -name "*.yml" -type f)

debug "Inspecting files [${DECRYPT_FILES}]"

for file_name in $DECRYPT_FILES; do

    DECRYPT_VARS=$(egrep "^[^ ].*:\s+\!vault" "${file_name}" -h | cut -d ':' -f 1)

    if [ "${DECRYPT_VARS}" != "" ]; then

        for var_name in ${DECRYPT_VARS}; do

            debug "Processing ${file_name}:${var_name}"
            TMPFILE="${TMPDIR}/$(basename "${file_name}")"
            encrypted=$(yq r "${file_name}" "${var_name}")
            if [ $? -ne 0 ]; then
                echo "error decrypting secret ${var_name} from file ${file_name}"
                exit "${KO}"
            fi

            decrypted=$(echo "${encrypted}" | ansible-vault decrypt)
            if [ $? -eq 0 ]; then
                echo "${file_name}:${var_name}:${decrypted}"
            else
                echo "error decrypting secret ${var_name} from file ${file_name}"
                exit "${KO}"
            fi

        done

    fi

done
