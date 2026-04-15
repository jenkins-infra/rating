#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

BASE_URL="http://localhost:8085"

wait_for_service() {
    for i in {1..10}; do
        if curl --silent --fail "${BASE_URL}/healthcheck.php" >/dev/null; then
            return 0
        fi
        sleep 1
    done
    echo "Service not ready after retries"
    return 1
}

setup() {
    wait_for_service
}

@test "service is healthy" {
    run curl --silent --fail "${BASE_URL}/healthcheck.php"
    assert_success
    assert_output "ok"
}

@test "submit ratings" {
    queries=(
        "version=3.001&rating=1"
        "version=3.002&rating=0&issue=99999"
        "version=3.003&rating=0&issue=https://github.com/jenkinsci/jenkins/issues/12345"
        "version=3.004&rating=0&issue=https://github.com/jenkinsci/jenkins/issues/67890%23issuecomment-123"
        "version=3.005&rating=-1&issue=11111"
    )

    for query in "${queries[@]}"; do
        run curl --silent --fail "${BASE_URL}/rate/submit.php?${query}"
        assert_success
    done
}

@test "result endpoint (JavaScript)" {
    run curl --silent --fail "${BASE_URL}/rate/result.php"
    assert_success

    assert_output --partial 'var data ='
    assert_output --partial '"3.001":'
    assert_output --partial '"3.002":'
    assert_output --partial '"3.003":'
    assert_output --partial '"3.004":'
    assert_output --partial '"3.005":'
}

@test "result endpoint (JSON)" {
    run curl --silent --fail "${BASE_URL}/rate/result.php?json=1"
    assert_success

    run curl --silent --dump-header - "${BASE_URL}/rate/result.php?json=1"
    headers="$(echo "${output}" | sed '/^\r$/q')"
    body="$(echo "${output}" | sed '1,/^\r$/d')"

    # Validate content-type
    [[ "${headers}" == *"Content-Type: application/json"* ]]

    # Validate JSON
    echo "${body}" | jq . >/dev/null

    # Validate specific keys
    echo "${body}" | jq -e '."3.001"' >/dev/null
    echo "${body}" | jq -e '."3.002"' >/dev/null
}

@test "result endpoint (JSONP)" {
    run curl --silent --fail "${BASE_URL}/rate/result.php?callback=testCallback"
    assert_success

    assert_output --partial 'testCallback('

    # Extract JSON from JSONP
    json=$(echo "${output}" | sed -E 's/^testCallback\((.*)\);$/\1/')

    # Validate JSON
    echo "$json" | jq . >/dev/null
}
