pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID   = '968234051261'                  // TODO: replace with your AWS account ID
        AWS_REGION       = 'ap-south-1'                    // TODO: replace with your AWS region
        ECR_REPO_NAME    = 'sample-app'
        IMAGE_TAG        = "${env.BUILD_NUMBER}"
        ECR_REGISTRY     = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_URI        = "${ECR_REGISTRY}/${ECR_REPO_NAME}:${IMAGE_TAG}"
        EC2_HOST         = 'ec2-user@43.205.134.177'       // TODO: replace with your EC2 user@ip
        CONTAINER_NAME   = 'sample-app'
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Pulling latest code from GitHub...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Test') {
            steps {
                echo 'Running basic tests...'
                sh '''
                    docker run --rm -d --name test-${BUILD_NUMBER} -p 3999:3000 ${ECR_REPO_NAME}:${IMAGE_TAG}
                    sleep 3
                    curl -f http://localhost:3999/health || (docker logs test-${BUILD_NUMBER} && exit 1)
                    docker stop test-${BUILD_NUMBER}
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                echo 'Logging in to ECR and pushing image...'
                withCredentials([usernamePassword(
                    credentialsId: 'aws-credentials',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} | \
                            docker login --username AWS --password-stdin ${ECR_REGISTRY}

                        docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${IMAGE_URI}
                        docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPO_NAME}:latest

                        docker push ${IMAGE_URI}
                        docker push ${ECR_REGISTRY}/${ECR_REPO_NAME}:latest
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo 'Deploying container to EC2...'
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} "
                            aws ecr get-login-password --region ${AWS_REGION} | \
                                docker login --username AWS --password-stdin ${ECR_REGISTRY} &&
                            docker pull ${ECR_REGISTRY}/${ECR_REPO_NAME}:latest &&
                            docker stop ${CONTAINER_NAME} || true &&
                            docker rm ${CONTAINER_NAME} || true &&
                            docker run -d --name ${CONTAINER_NAME} \
                                --restart unless-stopped \
                                -p 80:3000 \
                                ${ECR_REGISTRY}/${ECR_REPO_NAME}:latest
                        "
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline succeeded. Image ${IMAGE_URI} deployed to ${EC2_HOST}"
        }
        failure {
            echo '❌ Pipeline failed. Check the stage logs above.'
        }
        always {
            sh 'docker image prune -f || true'
        }
    }
}
