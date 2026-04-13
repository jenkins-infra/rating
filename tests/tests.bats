#!/usr/bin/env bats
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
    run wait_for_service
    [[ "${status}" -eq 0 ]]

    run curl --silent "http://localhost:8085/healthcheck.php"
    [[ "${status}" -eq 0 ]]
    [[ "${output}" == *"ok"* ]]
}

@test "submit ratings" {
    run curl --silent "http://localhost:8085/rate/submit.php?version=3.001&rating=1"
    [[ "${status}" -eq 0 ]]

    run curl --silent "http://localhost:8085/rate/submit.php?version=3.002&rating=0&issue=99999"
    [[ "${status}" -eq 0 ]]

    run curl --silent "http://localhost:8085/rate/submit.php?version=3.003&rating=0&issue=https://github.com/jenkinsci/jenkins/issues/12345"
    [[ "${status}" -eq 0 ]]

    run curl --silent "http://localhost:8085/rate/submit.php?version=3.004&rating=0&issue=https://github.com/jenkinsci/jenkins/issues/67890%23issuecomment-123"
    [[ "${status}" -eq 0 ]]

    run curl --silent "http://localhost:8085/rate/submit.php?version=3.005&rating=-1&issue=11111"
    [[ "${status}" -eq 0 ]]
}

@test "result endpoint (javascript)" {
    expected_output='var data = {"2.318":[1,0,0],"2.316":[1,0,0],"3.001":[1,0,0],"2.317":[0,0,1,"6817",1],"2.319":[0,1,0],"3.002":[0,1,0,"99999",1],"3.003":[0,1,0,"https:\/\/github.com\/jenkinsci\/jenkins\/issues\/12345",1],"3.004":[0,1,0,"https:\/\/github.com\/jenkinsci\/jenkins\/issues\/67890",1],"3.005":[0,0,1,"11111",1]};'

    run curl --silent "http://localhost:8085/rate/result.php"
    [[ "${status}" -eq 0 ]]


    [[ "${output}" == *"var data"* ]]
    [[ "${output}" == *'"3.001":'* ]]
    [[ "${output}" == *'"3.002":'* ]]
    [[ "${output}" == *'"3.003":'* ]]
    [[ "${output}" == *'"3.004":'* ]]
    [[ "${output}" == *'"3.005":'* ]]
    [[ "${output}" == "${expected_output}" ]]
}

@test "result endpoint (json)" {
    expected_output='{"2.318":[1,0,0],"2.316":[1,0,0],"3.001":[1,0,0],"2.317":[0,0,1,"6817",1],"2.319":[0,1,0],"3.002":[0,1,0,"99999",1],"3.003":[0,1,0,"https:\/\/github.com\/jenkinsci\/jenkins\/issues\/12345",1],"3.004":[0,1,0,"https:\/\/github.com\/jenkinsci\/jenkins\/issues\/67890",1],"3.005":[0,0,1,"11111",1]}'
    run curl --silent --dump-header - "http://localhost:8085/rate/result.php?json=1"

    [[ "${status}" -eq 0 ]]

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
    [[ "${status}" -eq 0 ]]

    [[ "${output}" == *"testCallback("* ]]
    [[ "${output}" == *'"3.001":'* ]]
    [[ "${output}" == "${expected_output}" ]]
}
