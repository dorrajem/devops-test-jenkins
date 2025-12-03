pipeline {
    agent any
	tools
{
	maven 'M2_HOME'
}
 

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/dorrajem/devops-test-jenkins.git'
            }
        }
        stage('Clean') {
            steps {
                sh 'mvn clean'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn compile'
            }
        }

        stage('SonarQube Analysis') {
	    environment{
			SONAR_HOST_URL = 'http://localhost:9000/'
			SONAR_AUTH_TOKEN= credentials('SONAR_AUTH_TOKEN')
            steps {
			sh 'mvn sonar:sonar -Dsonar.projectKey=devops_test_jenkins -Dsonar.host.url=$SONAR_HOST_URL   -Dsonar.login=$SONAR_AUTH_TOKEN'
            }
        }
    }
}
