pipeline {
  agent {
    docker {
      image 'zaralink/maven-docker-agent:v1'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock' // mount Docker socket to access the host's Docker daemon
    }
  }
  stages {
    stage('Checkout') {
      steps {
        sh 'echo passed'
        //git branch: 'master', url: 'https://github.com/steph-nnamani/ci-cd-with-docker-argocd.git'
      }
    }
    stage('Build and Test') {
      steps {
        // build the project and create a WAR file
        sh 'mvn clean package'
    }
    }
    stage('Static Code Analysis') {
      environment {
        SONAR_URL = "http://44.211.77.162:9000"
      }
      steps {
        withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
          sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
        }
      }
    }
    stage('Build and Push Docker Image to imageRegistry') {
      environment {
        DOCKER_IMAGE = "zaralink/ultimate-cicd:${BUILD_NUMBER}"
        // DOCKERFILE_LOCATION = "https://github.com/steph-nnamani/ci-cd-with-docker-argocd/Dockerfile"
        REGISTRY_CREDENTIALS = credentials('docker-cred')
      }
    steps {
        script {
            sh 'docker build -t ${DOCKER_IMAGE} .'
            def dockerImage = docker.image("${DOCKER_IMAGE}")
            docker.withRegistry('https://index.docker.io/v1/', "docker-cred") {
                dockerImage.push()
            }
        }
      }
    }
    stage('Update Deployment File') {
        environment {
            GIT_REPO_NAME = "personal-container-artifactory"
            GIT_USER_NAME = "snnamani"
        }
        steps {
            withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                sh '''
                    git config user.email "stephennnamani@yahoo.com"
                    git config user.name "Stephen Nnamani"
                    BUILD_NUMBER=${BUILD_NUMBER}
                    sed -i "s/replaceImageTag/${BUILD_NUMBER}/g" personal-container-artifactory/deployment.yml
                    git add personal-container-artifactory/deployment.yml
                    git commit -m "Updated deployment image to version ${BUILD_NUMBER}"
                    git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                '''
            }
         }
       }
      }
    }