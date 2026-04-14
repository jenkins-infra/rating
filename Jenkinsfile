node('arm64docker') {
    stage('checkout') {
        checkout scm
    }
    stage('test') {
        sh 'make test'
        junit(allowEmptyResults: true, keepLongStdio: true, testResults: 'target/junit-results.xml')
    }
}
