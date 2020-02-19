#!/usr/bin/env bash

KO=1
OK=0

VAULT_PASS_ID=$1
DECRYPT_DIR="inventory/${VAULT_PASS_ID}"
DECRYPT_FILES=$(find "${DECRYPT_DIR}" -name "*.yml" -type f)

for file_name in $DECRYPT_FILES; do

    DECRYPT_VARS=$(egrep "^[^ ].*:\s+\!vault" "${file_name}" -h | cut -d ':' -f 1)

    if [ "${DECRYPT_VARS}" != "" ]; then

        for var_name in ${DECRYPT_VARS}; do

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
