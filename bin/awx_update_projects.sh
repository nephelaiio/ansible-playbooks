#!/usr/bin/env bash

# global definitions
TRUE=0
FALSE=1
DEBUG=${FALSE}
ERROR=1
SUCCESS=0
PARAMS=$SUCCESS

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
        --repo)
            REPO="$2"
            shift # past argument
            shift # past value
            ;;
        --branch)
            BRANCH="$2"
            shift # past argument
            shift # past value
            ;;
        --debug)
            DEBUG=${TRUE}
            shift # past argument
            shift # past value
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
if [ -z "${REPO}" ]; then
    echo "--repo <project reposority url> option is required"
    PARAMS=${ERROR}
fi
if [ "${PARAMS}" == "${ERROR}" ]; then
    exit ${ERROR}
fi

# set defaults
if [ -z "${BRANCH}" ]; then
    BRANCH="master"
fi

tower-cli config host ${HOST} 2>&1 >/dev/null
tower-cli config username ${_USER} 2>&1 >/dev/null
tower-cli config password ${_PASS} 2>&1 >/dev/null
tower-cli config format json 2>&1 >/dev/null

# retrieve awx project ids
PRJS=$(tower-cli project list --scm-url ${REPO} --scm-branch ${BRANCH} | jq -cr '.results[] | {name,organization}')

if [ -z ${PRJS} ]; then

    echo "no projects found for repository ${REPO}"

else

    for PRJ in ${PRJS}; do

        debug testing project ${PRJ_NAME}

        PRJ_NAME=$(echo $PRJ | jq -r '.name')
        PRJ_ORG=$(echo $PRJ | jq -r '.organization')
        echo "updating project ${PRJ_NAME}"
        PRJ_UPDATE=$(tower-cli project update -n ${PRJ_NAME} --organization ${PRJ_ORG} --wait)

        if [ $? -ne 0 ]; then
            echo "unable to update project ${PRJ_ID}"
            echo "${PRJ_UPDATE}"
            exit ${ERROR}
        fi

    done

fi

exit ${SUCCESS}
