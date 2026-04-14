#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    wait_for_service
}

wait_for_service() {
    for i in {1..10}; do
        if curl --silent --fail "http://localhost:8085/healthcheck.php" >/dev/null; then
            return 0
        fi
        sleep 1
    done
    echo "Service not ready"
    return 1
}

@test "service is healthy" {
    run curl --silent "http://localhost:8085/healthcheck.php"
    assert_success
    assert_output 'ok'
}

@test "submit ratings" {
    run curl --silent "http://localhost:8085/rate/submit.php?version=3.001&rating=1"
    assert_success

    run curl --silent "http://localhost:8085/rate/submit.php?version=3.002&rating=0&issue=99999"
    assert_success

    run curl --silent "http://localhost:8085/rate/submit.php?version=3.003&rating=0&issue=https://github.com/jenkinsci/jenkins/issues/12345"
    assert_success

    run curl --silent "http://localhost:8085/rate/submit.php?version=3.004&rating=0&issue=https://github.com/jenkinsci/jenkins/issues/67890%23issuecomment-123"
    assert_success

    run curl --silent "http://localhost:8085/rate/submit.php?version=3.005&rating=-1&issue=11111"
    assert_success
}

@test "result endpoint (javascript)" {
    expected_output='var data = {"2.318":[1,0,0],"2.316":[1,0,0],"3.001":[1,0,0],"2.317":[0,0,1,"6817",1],"2.319":[0,1,0],"3.002":[0,1,0,"99999",1],"3.003":[0,1,0,"https:\/\/github.com\/jenkinsci\/jenkins\/issues\/12345",1],"3.004":[0,1,0,"https:\/\/github.com\/jenkinsci\/jenkins\/issues\/67890",1],"3.005":[0,0,1,"11111",1]};'

    run curl --silent "http://localhost:8085/rate/result.php"
    assert_success

    assert_output --partial 'var data'
    assert_output --partial '"3.001":'
    assert_output --partial '"3.002":'
    assert_output --partial '"3.003":'
    assert_output --partial '"3.004":'
    assert_output --partial '"3.005":'
    assert_output "${expected_output}"
}

@test "result endpoint (json)" {
    expected_output='{"2.318":[1,0,0],"2.316":[1,0,0],"3.001":[1,0,0],"2.317":[0,0,1,"6817",1],"2.319":[0,1,0],"3.002":[0,1,0,"99999",1],"3.003":[0,1,0,"https:\/\/github.com\/jenkinsci\/jenkins\/issues\/12345",1],"3.004":[0,1,0,"https:\/\/github.com\/jenkinsci\/jenkins\/issues\/67890",1],"3.005":[0,0,1,"11111",1]}'

    run curl --silent --dump-header - "http://localhost:8085/rate/result.php?json=1"
    assert_success

    # Split headers/body
    headers="$(echo "${output}" | sed '/^\r$/q')"
    body="$(echo "${output}" | sed '1,/^\r$/d')"

    [[ "${headers}" == *"Content-Type: application/json"* ]]
    [[ "${body}" == *'"3.001":'* ]]
    [[ "${body}" == "${expected_output}" ]]
}

@test "result endpoint (jsonp)" {
    expected_output='testCallback({"2.318":[1,0,0],"2.316":[1,0,0],"3.001":[1,0,0],"2.317":[0,0,1,"6817",1],"2.319":[0,1,0],"3.002":[0,1,0,"99999",1],"3.003":[0,1,0,"https:\/\/github.com\/jenkinsci\/jenkins\/issues\/12345",1],"3.004":[0,1,0,"https:\/\/github.com\/jenkinsci\/jenkins\/issues\/67890",1],"3.005":[0,0,1,"11111",1]});'

    run curl --silent "http://localhost:8085/rate/result.php?callback=testCallback"
    assert_success

    assert_output --partial 'testCallback('
    assert_output --partial '"3.001":'
    assert_output "${expected_output}"
}
