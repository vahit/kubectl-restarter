#!/bin/bash

CURRENT_SCALE=""
GOAL_SCALE=""
NAMESPACE=""
DEP_NAME=""
DEP_LIST=""
DOWN=""
UP=""
declare -a EXCEPT

while getopts ":n:o:e:d:u:r" opt; do
    case $opt in
        n) NAMESPACE=${OPTARG};;
        e) EXCEPT=${OPTARG};;
        o) DEPS_LIST=${OPTARG};;
        d) DOWN="TRUE"
           GOAL_SCALE="${OPTARG}";;
        u) UP="TRUE"
           GOAL_SCALE="${OPTARG}";;
        r) DOWN="TRUE"
           UP="TRUE"
           GOAL_SCALE=0;;
        :) echo "Option -${OPTARG} requires an argument." >&2
           exit 1;;
        \?) echo "Invalid options: ${OPTARG}" >&2
            exit 1;;
    esac
done

function scale_down(){
    NAMESPACE=${1}
    DEP_NAME=${2}
    CURRENT=${3}
    GOAL=${4}
    OUTPUT=$(kubectl --namespace "${NAMESPACE}" scale --current-replicas="${CURRENT}" --replicas="${GOAL}" deployment/"${DEP_NAME}")
    RETURN_CODE=${?}
    if [[ ${RETURN_CODE} -eq 0 ]]; then
<<<<<<< Updated upstream
        echo "${DEP_NAME} scaled DOWN to ${GOAL}."
=======
        echo "\"${DEPN}\" scaled to ${GOAL} successfuly."
>>>>>>> Stashed changes
    else
        echo -e "\e[5mError\e[0m: ${DEP_NAME} could not scale DOWN, ${OUTPUT}"
        exit 1
    fi
}

function scale_up(){
    NAMESPACE=${1}
    DEP_NAME=${2}
    CURRENT=${3}
    GOAL=${4}
    OUTPUT=$(kubectl --namespace "${NAMESPACE}" scale --current-replicas="${CURRENT}" --replicas="${GOAL}" deployment/"${DEP_NAME}")
    RETURN_CODE=${?}
    if [[ ${RETURN_CODE} -eq 0 ]]; then
        echo "${DEP_NAME} scaled UP to ${GOAL}."
    else
        echo -e "\e[5mError\e[0m: ${DEP_NAME} could not scale UP, ${OUTPUT}"
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
        if [[ ${DOWN} == "TRUE" ]]; then
            scale_down "${NAMESPACE}" "${EACH_DEP}" "${CURRENT_SCALE}" "${GOAL_SCALE}"
        fi
        if [[ ${UP} == "TRUE" && ${DOWN} == "TRUE" ]]; then
            scale_up "${NAMESPACE}" "${EACH_DEP}" "${GOAL_SCALE}" "${CURRENT_SCALE}"
        elif [[ ${UP} == "TRUE" && ${DOWN} != "TRUE" ]]; then
            scale_up "${NAMESPACE}" "${EACH_DEP}" "${CURRENT_SCALE}" "${GOAL_SCALE}"
        fi
    fi
done

exit 0
