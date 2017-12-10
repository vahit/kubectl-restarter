#!/bin/bash

while getopts ":n:e:" opt; do
    case $opt in
        n) NAMESPACE=${OPTARG};;
        e) EXCEPT=${OPTARG};;
        \?) echo "Invalid options: ${OPTARG}" >&2
            exit 1;;
        :) echo "Option -${OPTARG} requires an argument." >&2
           exit 1;;
    esac
done

if [[ -z ${1} ]]; then
    echo "You should be specified namespace."
    exit 1
fi

DEPS_LIST=$(kubectl --namespace "${NAMESPACE}" get deployment | grep -v NAME | awk '{print $1}')
for EACH_DEP in ${DEPS_LIST}; do
    if [[ ${EXCEPT} != *"${EACH_DEP}"* ]]; then
        CURRENT_SCALE=$(kubectl --namespace "${NAMESPACE}" get deployment "${EACH_DEP}" --output json | jq '.spec.replicas')
        OUTPUT=$(kubectl --namespace "${NAMESPACE}" scale --current-replicas="${CURRENT_SCALE}" --replicas=0 deployment/"${EACH_DEP}")
        RETURN_CODE=${?}
        if [[ ${RETURN_CODE} -eq 0 ]]; then
            sleep 2
            OUTPUT=$(kubectl --namespace "${NAMESPACE}" scale --current-replicas=0 --replicas="${CURRENT_SCALE}" deployment/"${EACH_DEP}")
            RETURN_CODE=${?}
            if [[ ${RETURN_CODE} -ne 0 ]]; then
                echo -e "\e[5mError\e[0m: ${EACH_DEP} --> ${OUTPUT}"
                exit 1
            else
                echo "${EACH_DEP}: RESTARTED."
            fi
        else
            echo -e "\e[5mError\e[0m: ${EACH_DEP} could not scale down, ${OUTPUT}"
        fi
    fi
done

exit 0
