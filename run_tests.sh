#!/usr/bin/env bash

ARGS=$*
NEO4J_VERSIONS="3.5 3.4 3.3 3.2"


function run_unit_tests
{
    echo "Running unit tests"
    coverage run --append --module pytest -v ${ARGS} test/unit
    STATUS="$?"
    if [[ ${STATUS} -ne 0 ]]
    then
        exit ${STATUS}
    fi
}


function run_integration_tests
{
    for NEO4J_VERSION in ${NEO4J_VERSIONS}
    do
        echo "Running standalone integration tests against Neo4j CE ${NEO4J_VERSION}"
        NEO4J_VERSION=${NEO4J_VERSION} coverage run --append --module pytest -v ${ARGS} test/integration_1
        STATUS="$?"
        if [[ ${STATUS} -ne 0 ]]
        then
            exit ${STATUS}
        fi
        if [[ "${PY2NEO_QUICK_TEST}" != "" ]]
        then
            return
        fi
    done
    run_integration_cc_tests
}


function run_integration_cc_tests
{
    for NEO4J_VERSION in ${NEO4J_VERSIONS}
    do
        echo "Running cluster integration tests against Neo4j EE ${NEO4J_VERSION}"
        NEO4J_VERSION=${NEO4J_VERSION} coverage run --append --module pytest -v ${ARGS} test/integration_cc
        STATUS="$?"
        if [[ ${STATUS} -ne 0 ]]
        then
            exit ${STATUS}
        fi
    done
}


pip install --upgrade --quiet coverage pytest
pip install --upgrade --quiet -r requirements.txt -r test_requirements.txt
coverage erase
run_unit_tests
run_integration_tests
coverage report
