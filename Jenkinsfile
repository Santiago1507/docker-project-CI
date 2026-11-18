pipeline {
    agent any

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        COMPOSE_PROJECT_NAME = 'entrega-semana3-jenkins'
        WORDPRESS_PORT = '8081'
        WP_CONTAINER_NAME = 'jenkins-wordpress'
        DB_CONTAINER_NAME = 'jenkins-mysql'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-credentials',
                    url: 'https://github.com/Santiago1507/docker-project-CI.git'
            }
        }

        stage('Build') {
            steps {
                withCredentials([
                    string(credentialsId: 'mysql-database', variable: 'MYSQL_DATABASE'),
                    string(credentialsId: 'mysql-user', variable: 'MYSQL_USER'),
                    string(credentialsId: 'mysql-password', variable: 'MYSQL_PASSWORD'),
                    string(credentialsId: 'mysql-root-password', variable: 'MYSQL_ROOT_PASSWORD')
                ]) {
                    sh 'docker compose config'
                    sh 'docker compose build'
                }
            }
        }

        stage('Test') {
            steps {
                withCredentials([
                    string(credentialsId: 'mysql-database', variable: 'MYSQL_DATABASE'),
                    string(credentialsId: 'mysql-user', variable: 'MYSQL_USER'),
                    string(credentialsId: 'mysql-password', variable: 'MYSQL_PASSWORD'),
                    string(credentialsId: 'mysql-root-password', variable: 'MYSQL_ROOT_PASSWORD'),
                    string(credentialsId: 'wordpress-admin-password', variable: 'WP_ADMIN_PASSWORD')
                ]) {
                    sh 'docker compose up -d'
                    sh 'bash jenkins/scripts/verify-communication.sh'
                }
            }
        }
    }

    post {
        always {
            sh 'docker compose down -v || true'
            cleanWs()
        }
        success {
            echo 'Pipeline finalizado: imágenes construidas y comunicación verificada.'
        }
        failure {
            echo 'Pipeline fallido: revisar la salida de consola de la etapa Test.'
        }
    }
}
