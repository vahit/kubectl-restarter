#!/bin/bash

CURRENT_SCALE=""
GOAL_SCALE=""
NAMESPACE=""
DEP_NAME=""
DEP_LIST=""
declare -a EXCEPT

while getopts ":n:o:e:s:r" opt; do
    case $opt in
        n) NAMESPACE=${OPTARG};;
        e) EXCEPT=${OPTARG};;
        o) DEPS_LIST=${OPTARG};;
        s) GOAL_SCALE="${OPTARG}";;
        r) RESTART="TRUE"
           GOAL_SCALE=0;;
        :) echo "Option -${OPTARG} requires an argument." >&2
           exit 1;;
        \?) echo "Invalid options: ${OPTARG}" >&2
            exit 1;;
    esac
done

function scale(){
    NAMES=${1}        # Namespace.
    DEPN=${2}         # Deployment name.
    CURRENT=${3}      # Current scale.
    GOAL=${4}         # Goal scale.
    OUTPUT=$(kubectl --namespace "${NAMES}" scale --current-replicas="${CURRENT}" --replicas="${GOAL}" deployment/"${DEPN}")
    RETURN_CODE=${?}
    if [[ ${RETURN_CODE} -eq 0 ]]; then
        echo "\"${DEPN}\" scaled to ${GOAL} successfuly."
    else
        echo -e "\e[5mError\e[0m: ${DEP_NAME} could not scale DOWN, ${OUTPUT}"
        exit 1
    fi
}

if [[ -z ${NAMESPACE} ]]; then
    echo "You should be specified namespace."
    exit 1
fi

if [[ -z ${DEPS_LIST} ]]; then
    DEPS_LIST=$(kubectl --namespace "${NAMESPACE}" get deployment | grep -v NAME | awk '{print $1}')
fi

for EACH_DEP in ${DEPS_LIST}; do
    if [[ "${EXCEPT[@]}" != *"${EACH_DEP}"* ]]; then
        CURRENT_SCALE=$(kubectl --namespace "${NAMESPACE}" get deployment "${EACH_DEP}" --output json | jq '.spec.replicas')
        if [[ ${RESTART} == "TRUE" ]]; then
            scale "${NAMESPACE}" "${EACH_DEP}" "${CURRENT_SCALE}" "${GOAL_SCALE}"
            scale "${NAMESPACE}" "${EACH_DEP}" "${GOAL_SCALE}" "${CURRENT_SCALE}"
        else
            scale "${NAMESPACE}" "${EACH_DEP}" "${CURRENT_SCALE}" "${GOAL_SCALE}"
        fi
    fi
done

exit 0
