#!/usr/bin/env bash

KO=1
OK=0

VAULT_PASS_ID=$1
REKEY_DIR="inventory/${VAULT_PASS_ID}"
VAULT_PASS_FILE="$HOME/.ansible_vault/${VAULT_PASS_ID}"
VAULT_PASS_DIR="$(dirname ${VAULT_PASS_FILE})"
VAULT_PASS_BASENAME="$(basename ${VAULT_PASS_FILE})"
VAULT_VERIFY=0
TMPROOT=temp

genxkpass() {
    curl -s 'https://xkpasswd.net/s/index.cgi' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' --data 'a=genpw&n=1&c=%7B%22num_words%22%3A4%2C%22word_length_min%22%3A4%2C%22word_length_max%22%3A8%2C%22case_transform%22%3A%22RANDOM%22%2C%22separator_character%22%3A%22-%22%2C%22padding_digits_before%22%3A2%2C%22padding_digits_after%22%3A2%2C%22padding_type%22%3A%22NONE%22%2C%22random_increment%22%3A%22AUTO%22%7D' | jq '.passwords[0]' -r
}

TMPDIR=$(mktemp -d --tmpdir=${TMPROOT})
REKEY_FILES=$(find "${REKEY_DIR}" -name "*.yml" -type f)

TMPVAULT="${TMPDIR}/vaults/${VAULT_PASS_BASENAME}"
mkdir "$(dirname ${TMPVAULT})"
echo "$(genxkpass)" > "${TMPVAULT}"

for file_name in $REKEY_FILES; do

    REKEY_VARS=$(egrep "^[^ ].*:\s+\!vault" "${file_name}" -h | cut -d ':' -f 1)

    if [ "${REKEY_VARS}" != "" ]; then

        for var_name in ${REKEY_VARS}; do

            TMPFILE="${TMPDIR}/$(basename "${file_name}")"
            encrypted=$(yq r "${file_name}" "${var_name}")
            if [ $? -ne 0 ]; then
                echo "error decrypting secret ${var_name} from file ${file_name}"
                exit "${KO}"
            fi

            if ! [[ "$encrypted" =~ "^\$ANSIBLE_VAULT;([^;]+;){2};${VAULT_PASS_ID}\n.*$" ]]; then

                if [ "${VAULT_VERIFY}" -eq 1 ]; then
                    echo "Ignoring ${file_name}:${var_name} with mismatched vault id"
                    continue
                fi

            fi

            decrypt_success=1
            for vault_pass_file in ${VAULT_PASS_FILE} $(find "${VAULT_PASS_DIR}/" -name ".${VAULT_PASS_BASENAME}*" -type f); do

                echo trying ${vault_pass_file}
                decrypted=$(echo "${encrypted}" | ansible-vault decrypt)
                if [ $? -ne 0 ]; then
                    continue;
                else
                    decrypt_success=0
                fi

            done
            if [ $decrypt_success -ne 0 ]; then
                echo "error decrypting secret ${var_name} from files ${file_name}*"
                exit "${KO}"
            fi

            recrypted=$(echo "${decrypted}" | ansible-vault encrypt_string --encrypt-vault-id "${VAULT_PASS_ID}" --vault-password-file "${TMPVAULT}")
            if [ $? -ne 0 ]; then
                echo "error encrypting secret ${var_name} from file ${file_name}"
                exit "${KO}"
            fi

            echo "---" > "${TMPFILE}"
            echo "${var_name}: ${recrypted}" >> "${TMPFILE}"
            yq m -x -i "${file_name}" "${TMPFILE}" -I 2
            echo -e "---\n$(cat ${file_name})" > "${file_name}"

        done

    fi

done

mv "${VAULT_PASS_FILE}" "${VAULT_PASS_DIR}/.${VAULT_PASS_BASENAME}.$(date +%Y%m%d%H%M%S)"
mv "${TMPVAULT}" "${VAULT_PASS_FILE}"

rm -rf ${TMPDIR}
