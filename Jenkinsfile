pipeline {
    agent any
    tools {
        maven 'M2_HOME'
    }
    
    environment {
        // Docker Hub credentials - REPLACE THESE WITH YOUR ACTUAL VALUES
        DOCKER_USERNAME = 'dorjem'
        DOCKER_PASSWORD = '221JFT4743'
        DOCKER_IMAGE = "${DOCKER_USERNAME}/devops-test-jenkins"
        DOCKER_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/dorrajem/devops-test-jenkins.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }
        
        stage('MVN SONARQUBE') {
            steps {
                sh '''
                    mvn sonar:sonar \
                      -Dsonar.projectKey=devops-test-jenkins \
                      -Dsonar.host.url=http://127.0.0.1:9000 \
                      -Dsonar.login=sqa_fa305978069c6ce615a002d5d4192a86913a13a2
                '''
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    // Build Docker image
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    
                    // Also tag as latest
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                }
            }
        }
        
        stage('Docker Login') {
            steps {
                script {
                    // Login to Docker Hub using embedded credentials
                    sh """
                        echo '${DOCKER_PASSWORD}' | docker login -u '${DOCKER_USERNAME}' --password-stdin
                    """
                }
            }
        }
        
        stage('Docker Push') {
            steps {
                script {
                    // Push both tags
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }
        
        stage('Deploy with Compose') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Create docker-compose.yml file
                    writeFile file: 'docker-compose.prod.yml', text: """
version: '3.8'
services:
  devops-test-jenkins:
    image: ${DOCKER_IMAGE}:latest
    container_name: devops-jenkins-app
    ports:
      - "8080:8080"
    restart: unless-stopped
    environment:
      - SPRING_PROFILES_ACTIVE=production
"""
                    
                    // Deploy
                    sh 'docker-compose -f docker-compose.prod.yml up -d'
                }
            }
        }
    }
    
post {
    always {
        script {
            // Vérifier si des fichiers JAR existent avant d'archiver
            def jarFiles = findFiles(glob: 'target/*.jar')
            if (!jarFiles.isEmpty()) {
                echo "Archiving ${jarFiles.size()} JAR file(s)"
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            } else {
                echo "No JAR files found to archive in target/"
            }
        }
        
        sh 'docker logout || true'
        cleanWs()
    }
    success {
        echo "✅ Pipeline succeeded! Docker image pushed: ${DOCKER_IMAGE}:${DOCKER_TAG}"
    }
    failure {
        echo "❌ Pipeline failed!"
    }
}
}
