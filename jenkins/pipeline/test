@Library('bhevs-shared-library') _

pipeline {
    agent { label 'windows-server-agent' }

    stages {
        stage('Jenkins Echo (Platform Independent)') {
            steps {
                echo 'Hello World - from Jenkins echo'
            }
        }
    }
}