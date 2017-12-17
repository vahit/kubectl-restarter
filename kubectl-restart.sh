#!/bin/bash

NAMESPACE=${}
DEP_NAME=${}
EXCEPT=${}

while getopts ":n:e:" opt; do
    case $opt in
        n) NAMESPACE=${OPTARG};;
        e) EXCEPT=${OPTARG};;
        \?) echo "Invalid options: ${OPTARG}" >&2
            exit 1;;
        o) DEP_NAME=${OPTARG};;
        :) echo "Option -${OPTARG} requires an argument." >&2
           exit 1;;
    esac
done


function restart_pod(){
    NAMESPACE=${1}
    DEP_NAME=${2}
    CURRENT_SCALE=$(kubectl --namespace "${NAMESPACE}" get deployment "${DEP_NAME}" --output json | jq '.spec.replicas')
    OUTPUT=$(kubectl --namespace "${NAMESPACE}" scale --current-replicas="${CURRENT_SCALE}" --replicas=0 deployment/"${DEP_NAME}")
    RETURN_CODE=${?}
    if [[ ${RETURN_CODE} -eq 0 ]]; then
        sleep 2
        OUTPUT=$(kubectl --namespace "${NAMESPACE}" scale --current-replicas=0 --replicas="${CURRENT_SCALE}" deployment/"${DEP_NAME}")
        RETURN_CODE=${?}
        if [[ ${RETURN_CODE} -ne 0 ]]; then
            echo -e "\e[5mError\e[0m: ${DEP_NAME} --> ${OUTPUT}"
            exit 1
        else
            echo "${DEP_NAME}: RESTARTED."
        fi
    else
        echo -e "\e[5mError\e[0m: ${DEP_NAME} could not scale down, ${OUTPUT}"
    fi
}

if [[ -z ${NAMESPACE} ]]; then
    echo "You should be specified namespace."
    exit 1
fi

if [[ ! -z ${DEP_NAME} ]]; then
    restart_pod ${NAMESPACE} ${DEP_NAME}
    exit 0
fi

DEPS_LIST=$(kubectl --namespace "${NAMESPACE}" get deployment | grep -v NAME | awk '{print $1}')
for EACH_DEP in ${DEPS_LIST}; do
    if [[ ${EXCEPT} != *"${EACH_DEP}"* ]]; then
        restart_pod ${NAMESPACE} ${EACH_DEP}
    fi
done

exit 0
