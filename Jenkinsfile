pipeline {
    // 1. Agent Configuration
    // Use a Docker container with a specific version of Terraform.
    // This ensures that the environment is clean and consistent for every run.
    agent {
        docker {
            image 'hashicorp/terraform:1.5.0'
            args '-u root' // Run as root to avoid permission issues inside the container
        }
    }

    // 2. Environment Variables
    // Securely injects AWS credentials managed by the Jenkins Credentials Manager.
    environment {
        // These credentials must be configured in Jenkins with the specified IDs.
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'us-east-1' // Change to your desired AWS region
        TF_IN_AUTOMATION      = 'true' // Disables interactive prompts from Terraform
    }

    // 3. Pipeline Stages
    // The workflow is broken down into sequential stages.
    stages {
        stage('Checkout Code') {
            steps {
                // Clones the repository into the Jenkins workspace.
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                // Initializes the Terraform working directory by downloading providers.
                sh 'terraform init'
            }
        }

        stage('Select Terraform Workspace') {
            steps {
                script {
                    // Use separate workspaces for 'dev' and 'main' branches to isolate states.
                    if (env.BRANCH_NAME == 'dev') {
                        echo "Selecting 'dev' workspace for test environment."
                        sh 'terraform workspace select dev || terraform workspace new dev'
                    } else if (env.BRANCH_NAME == 'main') {
                        echo "Selecting 'default' workspace for production environment."
                        sh 'terraform workspace select default'
                    }
                }
            }
        }

        stage('Terraform Validate & Format') {
            steps {
                // Validates the syntax of the Terraform configuration.
                sh 'terraform validate'
                // Checks if the code is correctly formatted.
                sh 'terraform fmt -check'
            }
        }

        stage('Terraform Plan') {
            steps {
                // Generates an execution plan and saves it to a file.
                // The -no-color flag is used for clean log output.
                sh 'terraform plan -no-color -out=tfplan'
                // Stash the plan file to make it available for the Apply stage.
                stash name: 'tfplan-archive', includes: 'tfplan'
            }
        }

        stage('Auto-Apply to Test') {
            // This stage runs ONLY for the 'dev' branch.
            when {
                branch 'dev'
            }
            steps {
                echo 'Applying plan automatically to the TEST environment for the dev branch.'
                unstash 'tfplan-archive'
                sh 'terraform apply -auto-approve tfplan'
            }
        }
