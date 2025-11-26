pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'mattjoe/calculator'
        DOCKER_TAG = 'latest'
        DOCKER = '/usr/local/bin/docker'   // <<── ADDED THIS
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/MJTheGreat3/se_lab_cicd.git'
                echo 'Successfully checked out code from repository'
            }
        }
        
        stage('Build') {
            steps {
                script {
                    sh '''
                        echo "=== BUILD STAGE STARTING ==="
                        if ! command -v mvn &> /dev/null; then
                            echo "Installing Maven manually..."
                            curl -O https://archive.apache.org/dist/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz
                            tar -xzf apache-maven-3.9.4-bin.tar.gz
                            export PATH=$PWD/apache-maven-3.9.4/bin:$PATH
                            echo "Maven installed at: $PWD/apache-maven-3.9.4/bin/mvn"
                        else
                            echo "Maven already available"
                        fi
                        echo "Running Maven compile..."
                        $PWD/apache-maven-3.9.4/bin/mvn clean compile
                    '''
                    echo 'Application compiled successfully'
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    sh '''
                        echo "Running Maven tests..."
                        $PWD/apache-maven-3.9.4/bin/mvn test
                    '''
                    echo 'Tests completed successfully'
                }
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
                success {
                    echo 'All tests passed!'
                }
                failure {
                    echo 'Tests failed! Pipeline will stop.'
                }
            }
        }
        
        stage('Package') {
            steps {
                script {
                    sh '''
                        echo "Packaging Java application..."
                        $PWD/apache-maven-3.9.4/bin/mvn package -DskipTests
                    '''
                    echo 'Application packaged successfully'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh '''
                        if command -v ${DOCKER} &> /dev/null; then
                            export DOCKER_CONFIG=/tmp
                            echo '{"credsStore": ""}' > /tmp/config.json
                            ${DOCKER} build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        else
                            echo "Docker not available, skipping Docker image build"
                        fi
                    '''
                    echo 'Docker image build completed'
                }
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                script {
                    echo 'Pushing Docker image to DockerHub...'
                    
                    script {
                        if (sh(script: "command -v ${DOCKER} &> /dev/null", returnStatus: true) == 0) {
                            withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                                sh '''
                                    export DOCKER_CONFIG=/tmp
                                    export HTTP_PROXY=""
                                    export HTTPS_PROXY=""
                                    export NO_PROXY="registry-1.docker.io,docker.io"
                                    echo '{"credsStore": ""}' > /tmp/config.json
                                    echo ${DOCKER_PASS} | ${DOCKER} login -u ${DOCKER_USER} --password-stdin
                                '''
                            }
                            
                            sh '''
                                export DOCKER_CONFIG=/tmp
                                export HTTP_PROXY=""
                                export HTTPS_PROXY=""
                                export NO_PROXY="registry-1.docker.io,docker.io"
                                ${DOCKER} push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            '''
                        } else {
                            echo "Docker not available, skipping Docker push"
                        }
                    }
                    
                    script {
                        if (sh(script: "command -v ${DOCKER} &> /dev/null", returnStatus: true) == 0) {
                            sh 'DOCKER_CONFIG=/tmp ${DOCKER} logout'
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
            echo "Docker image ${DOCKER_IMAGE}:${DOCKER_TAG} is available on DockerHub"
        }
        failure {
            echo 'Pipeline failed! Please check the logs above.'
        }
    }
}
