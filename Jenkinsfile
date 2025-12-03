pipeline {
    agent any

    environment {
        // Sonar token stored in Jenkins credentials (type: "Secret text")
        SONAR_TOKEN = credentials('SONAR_AUTH_TOKEN') 
    }

    stages {
        stage('Checkout') {
            steps {
                // No credentials needed if the repo is public
                git branch: 'main', url: 'https://github.com/dorrajem/devops-test-jenkins.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                // Pass the token to Maven
                sh "mvn sonar:sonar -Dsonar.projectKey=devops-test -Dsonar.projectName=devops-test-jenkins -Dsonar.host.url=http://localhost:9000 -Dsonar.login=$SONAR_TOKEN"
            }
        }
    }
}
