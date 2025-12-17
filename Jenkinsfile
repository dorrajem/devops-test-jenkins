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
        K8S_NAMESPACE = 'devops'
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
    stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "🚀 Déploiement sur Kubernetes..."
                    
                    // Créer le namespace s'il n'existe pas
                    sh "kubectl create namespace ${K8S_NAMESPACE} 2>/dev/null || true"
                    
                    // 1. Déployer MySQL
                    sh """
                        kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: ${K8S_NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: root123
        - name: MYSQL_DATABASE
          value: springdb
        ports:
        - containerPort: 3306
EOF
                    """
                    
                    // 2. Créer le service MySQL
                    sh """
                        kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  namespace: ${K8S_NAMESPACE}
spec:
  selector:
    app: mysql
  ports:
    - port: 3306
      targetPort: 3306
  type: ClusterIP
EOF
                    """
                    
                    // Attendre que MySQL soit prêt
                    sh "sleep 30"
                    
                    // 3. Déployer l'application Spring Boot
                    sh """
                        kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-app
  namespace: ${K8S_NAMESPACE}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: spring-app
  template:
    metadata:
      labels:
        app: spring-app
    spec:
      containers:
      - name: spring-app
        image: ${DOCKER_IMAGE}:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_DATASOURCE_URL
          value: jdbc:mysql://mysql-service:3306/springdb
        - name: SPRING_DATASOURCE_USERNAME
          value: root
        - name: SPRING_DATASOURCE_PASSWORD
          value: root123
EOF
                    """
                    
                    // 4. Créer le service NodePort
                    sh """
                        kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: spring-service
  namespace: ${K8S_NAMESPACE}
spec:
  selector:
    app: spring-app
  ports:
    - port: 8080
      targetPort: 8080
      nodePort: 30080
  type: NodePort
EOF
                    """
                    
                    echo "✅ Déploiement Kubernetes terminé"
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    echo "🔍 Vérification du déploiement..."
                    
                    // Attendre que les pods soient prêts
                    sh "sleep 60"
                    
                    // Vérifier l'état
                    sh """
                        echo "=== Pods ==="
                        kubectl get pods -n ${K8S_NAMESPACE}
                        
                        echo "=== Services ==="
                        kubectl get svc -n ${K8S_NAMESPACE}
                        
                        echo "=== Logs Spring Boot ==="
                        kubectl logs -n ${K8S_NAMESPACE} -l app=spring-app --tail=10 || echo "Logs non disponibles encore"
                    """
                    
                    // Tester l'application
                    sh """
                        URL=\$(minikube service spring-service -n ${K8S_NAMESPACE} --url 2>/dev/null || echo "")
                        if [ -n "\$URL" ]; then
                            echo "🌐 URL de l'application: \$URL"
                            echo "Testing application health..."
                            curl -f \$URL/actuator/health && echo "✅ Application is healthy!" || echo "⚠️ Application health check failed"
                        else
                            echo "⚠️ Could not get service URL"
                        fi
                    """
                }
            }
        }
    }
    
    post {
        always {
            // Archiver avant de nettoyer
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            
            sh 'docker logout || true'
            cleanWs()
        }
        success {
            echo "✅ PIPELINE SUCCESS!"
            echo "🎉 Docker image pushed successfully"
            echo "📦 ${DOCKER_IMAGE}:${DOCKER_TAG}"
            echo "🏷️ ${DOCKER_IMAGE}:latest"
        }
        failure {
            echo "❌ PIPELINE FAILED!"
        }
    }
}
