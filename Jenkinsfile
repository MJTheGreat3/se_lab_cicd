pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "mattjoe/calculator"
        DOCKER_TAG = "latest"
        MAVEN_HOME = "/usr/local/bin/mvn"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/MJTheGreat3/se_lab_cicd.git'
                echo "Source code checked out"
            }
        }

        stage('Build') {
            steps {
                sh '''
                    echo "=== COMPILING JAVA PROJECT ==="
                    mvn -version
                    mvn clean compile
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    echo "=== RUNNING TESTS ==="
                    mvn test
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
                    echo "=== PACKAGING JAR ==="
                    mvn package -DskipTests
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "=== BUILDING DOCKER IMAGE ==="
                    docker --version
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred',
                                                 usernameVariable: 'DOCKER_USER',
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "=== LOGGING IN TO DOCKER HUB ==="
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin

                        echo "=== PUSHING IMAGE ==="
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}

                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed — check above logs."
        }
    }
}
