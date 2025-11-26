pipeline {
    agent any

    environment {
        MVN = "/opt/homebrew/bin/mvn"
        DOCKER = "/usr/local/bin/docker"
        DOCKER_IMAGE = "mattjoe/calculator"
        DOCKER_TAG = "latest"

        // Disable Docker credential helper for Jenkins
        DOCKER_CONFIG = "/tmp/docker-config"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/MJTheGreat3/se_lab_cicd.git'
            }
        }

        stage('Build') {
            steps {
                sh '''
                    $MVN clean compile
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    $MVN test
                '''
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package') {
            steps {
                sh '''
                    $MVN package -DskipTests
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "=== SETTING UP DOCKER CONFIG ==="
                    mkdir -p $DOCKER_CONFIG
                    echo '{"credsStore": ""}' > $DOCKER_CONFIG/config.json

                    echo "=== BUILDING DOCKER IMAGE ==="
                    $DOCKER build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred',
                                                 usernameVariable: 'DOCKER_USER',
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "=== DOCKER LOGIN ==="
                        mkdir -p $DOCKER_CONFIG
                        echo '{"credsStore": ""}' > $DOCKER_CONFIG/config.json

                        echo "${DOCKER_PASS}" | $DOCKER login -u "${DOCKER_USER}" --password-stdin

                        echo "=== PUSHING IMAGE ==="
                        $DOCKER push ${DOCKER_IMAGE}:${DOCKER_TAG}

                        $DOCKER logout || true
                    '''
                }
            }
        }
    }
}
