pipeline {
    agent any
    tools {
        maven "M2_HOME"
    }

    stages {
        stage('GIT') {
            steps {
                git branch:'main',
                url: 'https://github.com/dorrajem/devops-test-jenkins.git'
            }
        }
    }
}
