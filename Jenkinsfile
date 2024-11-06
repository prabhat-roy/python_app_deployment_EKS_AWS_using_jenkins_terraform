def gv_script
pipeline {
    agent any
    environment {
         GITHUB_URL = "https://github.com/prabhat-roy/python_app_deployment_EKS_AWS_using_jenkins_terraform.git"
         BRANCH = "main"
         SCANNER_HOME =tool "SonarQube"
         IMAGE_NAME = "python-sample-image"         
         ACC_ID = "873330726955"
         REGION = "us-east-1"
         ECR = "${ACC_ID}.dkr.ecr.${REGION}.amazonaws.com"
    }
    stages {
        stage("Init") {
            steps {
                script {
                    gv_script = load"script.groovy"
                }
            }
        }
        stage("Clean Workspace") {
            steps {
                script {
                    gv_script.clean()
                }
            }
        }
        stage("Checkout from Git Repo") {
            steps {
                script {
                    gv_script.checkout()
                }
            }
        }
        stage("OWASP FS Scan") {
            steps {
                script {
                    gv_script.owasp()
                }
            }
        }
        stage("SonarQube Analysis") {
            steps {
                script {
                    gv_script.sonaranalysis()
                }
            }
        }
        stage("Trivy FS Scan") {
            steps {
                script {
                    gv_script.trivyfs()
                }
            }
        }
        stage("Docker Image") {
            steps {
                script {
                    gv_script.docker()
                }
            }
        }
        stage("Trivy Image Scan") {
            steps {
                script {
                    gv_script.trivyimage()
                }
            }
        }
        stage("Grype Image Scan") {
            steps {
                script {
                    gv_script.grype()
                }
            }
        }
        stage("Syft Image Scan") {
            steps {
                script {
                    gv_script.syft()
                }
            }
        }
        stage("Docker Scout Image Scan") {
            steps {
                script {
                    gv_script.dockerscout()
                }
            }
        }
        stage("AWS ECR login and push") {
            steps {
                script {
                    gv_script.ecr()
                }
            }
        }
        stage("Kubernetes deployment using Helm") {
            steps {
                script {
                    gv_script.deploy()
                }
            }
        }
        stage("Remove docker images") {
            steps {
                script {
                    gv_script.removedocker()
                }
            }
        } 
    }
    post {
        always {
            sh "docker logout"
            deleteDir()
        }
    }
}
