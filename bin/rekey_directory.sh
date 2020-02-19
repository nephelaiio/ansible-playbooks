#!/usr/bin/env bash

# global definitions
KO=1
OK=0
TRUE=0
FALSE=1
DEBUG=${FALSE}

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

function genxkpass() {
    curl -s 'https://xkpasswd.net/s/index.cgi' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' --data 'a=genpw&n=1&c=%7B%22num_words%22%3A4%2C%22word_length_min%22%3A4%2C%22word_length_max%22%3A8%2C%22case_transform%22%3A%22RANDOM%22%2C%22separator_character%22%3A%22-%22%2C%22padding_digits_before%22%3A2%2C%22padding_digits_after%22%3A2%2C%22padding_type%22%3A%22NONE%22%2C%22random_increment%22%3A%22AUTO%22%7D' | jq '.passwords[0]' -r
}

check_requirement ansible-vault
check_requirement yq
check_requirement curl

# set default values
REKEY_FORCE=${FALSE}
VAULT_VERIFY=${FALSE}
TMPROOT=temp
TMPDIR=$(mktemp -d --tmpdir=${TMPROOT})

# parse options (https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash)
POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --vault-id)
            VAULT_PASS_ID="$2"
            shift # past argument
            shift # past value
            ;;
        --vault-dir)
            ANSIBLE_VAULT_IDENTITY_DIR="$2"
            shift # past argument
            shift # past value
            ;;
        --rekey)
            REKEY_FORCE=${TRUE}
            shift # past argument
            shift # past value
            ;;
        --verify)
            VAULT_VERIFY=${TRUE}
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
if [ -z "${ANSIBLE_VAULT_IDENTITY_DIR}" ]; then
    ANSIBLE_VAULT_IDENTITY_DIR=".ansible_vault"
fi
if [ -z "${VAULT_PASS_ID}" ]; then
    echo "--vault-id <vault id> option is required"
    exit ${KO}
fi
if [ ${#POSITIONAL[@]} -gt 0 ]; then
    echo "Unknown positional arguments ${POSITIONAL[@]}"
    exit ${KO}
fi

# set derived values
REKEY_DIR="inventory/${VAULT_PASS_ID}"
VAULT_PASS_FILE="$HOME/${ANSIBLE_VAULT_IDENTITY_DIR}/${VAULT_PASS_ID}"
REKEY_FILES=$(find "${REKEY_DIR}" -name "*.yml" -type f)
TMPVAULT="${TMPDIR}/vaults/$(basename ${VAULT_PASS_FILE})"

if [ ! -d "$(dirname ${VAULT_PASS_FILE})" ]; then
    mkdir "$(dirname ${VAULT_PASS_FILE})"
    debug "Created vault password file directory $(dirname ${VAULT_PASS_FILE})"
fi

debug "Generating temp vault password file"

mkdir "$(dirname ${TMPVAULT})"
if [ ${REKEY_FORCE} -eq ${TRUE} ]; then
    debug "Generating new vault password"
    echo "$(genxkpass)" > "${TMPVAULT}"
else
    if [ -f "${VAULT_PASS_FILE}" ]; then
        cp "${VAULT_PASS_FILE}" "${TMPVAULT}"
    else
        echo "missing vault password file ${VAULT_PASS_FILE} ... aborting"
        exit ${KO}
    fi
fi

debug "Inspecting files [${REKEY_FILES}]"

for file_name in $REKEY_FILES; do

    REKEY_VARS=$(egrep "^[^ ].*:\s+\!vault" "${file_name}" -h | cut -d ':' -f 1)

    if [ "${REKEY_VARS}" != "" ]; then

        for var_name in ${REKEY_VARS}; do

            debug "Processing ${file_name}:${var_name}"
            TMPFILE="${TMPDIR}/$(basename "${file_name}")"
            encrypted=$(yq r "${file_name}" "${var_name}")
            if [ $? -ne 0 ]; then
                echo "error decrypting secret ${var_name} from file ${file_name}"
                exit "${KO}"
            fi

            if ! [[ "$encrypted" =~ "^\$ANSIBLE_VAULT;([^;]+;){2};${VAULT_PASS_ID}\n.*$" ]]; then

                if [ ${VAULT_VERIFY} -eq ${TRUE}  ]; then
                    echo "Ignoring ${file_name}:${var_name} with mismatched vault id"
                    continue
                fi

            fi

            decrypted=$(echo "${encrypted}" | ansible-vault decrypt --vault-id "${VAULT_PASS_ID}@${VAULT_PASS_FILE}")
            if [ $? -ne 0 ]; then
                echo "error decrypting secret ${var_name} from file ${file_name}"
                exit "${KO}"
            fi

            recrypted=$(echo "${decrypted}" | ansible-vault encrypt_string --encrypt-vault-id "${VAULT_PASS_ID}" --vault-password-file ${TMPVAULT})
            if [ $? -ne 0 ]; then
                echo "error encrypting secret ${var_name} from file ${file_name}"
                exit "${KO}"
            fi

            echo "---" > "${TMPFILE}"
            echo "${var_name}: ${recrypted}" >> "${TMPFILE}"
            yq m -x -i "${file_name}" "${TMPFILE}" -I 2

        done

    fi

done

if [ ${REKEY_FORCE} -eq ${TRUE} ]; then
    if [ -f "${VAULT_PASS_FILE}" ]; then
        mv "${VAULT_PASS_FILE}" "${VAULT_PASS_FILE}.$(date +%Y%m%d%H%M%S)"
    fi
    mv "${TMPVAULT}" "${VAULT_PASS_FILE}"
fi

rm -rf ${TMPDIR}
