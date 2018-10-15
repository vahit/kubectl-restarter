#!/bin/bash

while getopts ":n:o:e:" opt; do
    case $opt in
        n) NAMESPACE=${OPTARG};;
        e) EXCEPT=${OPTARG};;
        o) DEPS_LIST=${OPTARG};;
        :) echo "Option -${OPTARG} requires an argument." >&2
           exit 1;;
        \?) echo "Invalid options: ${OPTARG}" >&2
            exit 1;;
    esac
done

NAMESPACE=${NAMESPACE:-default}

function restart(){
    POD_LIST=$(kubectl --namespace "${NAMESPACE}" get pod --output custom-columns=NAME:.metadata.name --no-headers | grep "^${EACH_DEP}")
    for EACH_POD in ${POD_LIST}; do
        kubectl --namespace "${NAMESPACE}" delete pod "${EACH_POD}"
        sleep 2
    done
    unset POD_LIST
}

if [[ -z ${DEPS_LIST} ]]; then
    # That means we want restart all of deployments in the namespace.
    DEPS_LIST=$(kubectl --namespace "${NAMESPACE}" get deployment --output custom-columns=NAME:.metadata.name --no-headers )
fi

for EACH_DEP in ${DEPS_LIST}; do
    if [[ "${EXCEPT[@]}" != *"${EACH_DEP}"* ]]; then
        restart "${EACH_DEP}"
    fi
done

exit 0
