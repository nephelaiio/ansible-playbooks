#!/usr/bin/env bash

# global definitions
TRUE=0
FALSE=1
DEBUG=${FALSE}
ERROR=1
SUCCESS=0
PARAMS=$SUCCESS
FOUND=${FALSE}

function check_requirement {
    cmd=$1
    command -v ${cmd} >/dev/null 2>&1 || {
        echo "${cmd} not found, aborting"
        exit $ERROR
    }
}

function debug {
    if [ ${DEBUG} -eq ${TRUE} ]; then
        echo $@
    fi
}

check_requirement git
check_requirement tower-cli
check_requirement jq

# parse options (https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash)
POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --host)
            HOST="$2"
            shift # past argument
            shift # past value
            ;;
        --user)
            _USER="$2"
            shift # past argument
            shift # past value
            ;;
        --pass)
            _PASS="$2"
            shift # past argument
            shift # past value
            ;;
        --template)
            TEMPLATE="$2"
            shift # past argument
            shift # past value
            ;;
        --debug)
            DEBUG=${TRUE}
            shift # past argument
            ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# validate options
if [ -z "${HOST}" ]; then
    echo "--host <awx host> option is required"
    PARAMS=${ERROR}
fi
if [ -z "${_USER}" ]; then
    echo "--user <awx api user> option is required"
    PARAMS=${ERROR}
fi
if [ -z "${_PASS}" ]; then
    echo "--pass <awx api password> option is required"
    PARAMS=${ERROR}
fi
if [ -z "${TEMPLATE}" ]; then
    echo "--template <awx template name> option is required"
    PARAMS=${ERROR}
fi

# set defaults
TRIGGERS=$@
RUN=${FALSE}

if [ -z "${TRIGGERS}" ]; then

    RUN=${TRUE}
    debug "no triggers set, forcing execution"

else

    debug "checking for changes in ${TRIGGERS[@]}"

    for change in $(git diff --name-only HEAD HEAD~1); do

        for trigger in ${TRIGGERS}; do

            if [ $(echo "${change}" | grep "${trigger}") ]; then

                debug "trigger ${trigger} matched changeset file ${change}"
                RUN=${TRUE}
                break 2

            fi

        done

    done

fi

tower-cli config host ${HOST} 2>&1 >/dev/null
tower-cli config username ${_USER} 2>&1 >/dev/null
tower-cli config password ${_PASS} 2>&1 >/dev/null
tower-cli config format json 2>&1 >/dev/null

if [ ${RUN} -eq ${FALSE} ]; then

    echo "no triggers matched, checked ${TRIGGERS[@]}"

else

    TPL_RUN=$(tower-cli job launch --job-template ${TEMPLATE} --wait)

    if [ $? -ne 0 ]; then

        echo "${TPL_RUN}"
        exit ${ERROR}

    fi

fi

exit ${SUCCESS}
