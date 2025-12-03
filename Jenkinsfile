pipeline {
    agent any

    tools {
        maven "M2_HOME"
    }

    environment {
        SONAR_SERVER = "sonar"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/dorrajem/devops-test-jenkins.git'
            }
        }

        stage('Build') {
            steps {
                sh "mvn clean install -DskipTests"
            }
        }

stage('SonarQube Analysis') {
    steps {
        withCredentials([string(credentialsId: 'SONAR_AUTH_TOKEN', variable: 'SONAR_AUTH_TOKEN')]) {
            withSonarQubeEnv("${SONAR_SERVER}") {
                sh """
                   mvn sonar:sonar \
                   -Dsonar.projectKey=devops-test \
                   -Dsonar.projectName='devops-test' \
                   -Dsonar.host.url=http://localhost:9000 \
                   -Dsonar.login=${SONAR_AUTH_TOKEN}
                """
            }
        }
    }
}

        stage("Quality Gate") {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }
}
