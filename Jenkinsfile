node('arm64docker') {
    stage('checkout') {
        checkout scm
    }
    stage('test') {
        sh 'make test'
    }
}
