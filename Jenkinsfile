node('arm64docker') {
    stage('checkout') {
        checkout scm
    }

    stage('build') {
        sh 'make build'
    }

    stage('test') {
        sh 'make test'
        junit(allowEmptyResults: true, keepLongStdio: true, testResults: 'target/junit-results.xml')
    }
}
