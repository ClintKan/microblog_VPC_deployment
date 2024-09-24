
pipeline {
  agent any
    stages {
        stage ('Build') {
            steps {
                sh '''
                #!/bin/bash
                echo "Checking regular updates & installing them"
                sudo apt update
                sudo apt upgrade -y
                sudo add-apt-repository ppa:deadsnakes/ppa -y
                sudo apt install python3.9 python3-pip python3.9-venv -y
                python3.9 -m venv virtual
                . virtual/bin/activate # used . instead of source
                pip install -r requirements.txt
                '''
            }
        }
        stage ('Test') {
            steps {
                sh '''#!/bin/bash
                source virtual/bin/activate
                export FLASK_APP=microblog.py
                py.test ./tests/unit/test_app.py --verbose --junit-xml test-reports/results.xml
                '''
            }
            post {
                always {
                    junit 'test-reports/results.xml'
                }
            }
        }
    //   stage ('OWASP FS SCAN') {
    //         environment {
    //             NVD-APIKEY = credentials("NVD-ApiKey")
    //         }
    //         steps {
    //             dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey ${NVD-APIKEY}', odcInstallation: 'DP-Check'
    //             dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
    //         }
    //     }
      stage ('Deploy') {
            steps {
                sh '''#!/bin/bash
                ssh -i ~/.ssh/id_ed25519 ubuntu@170.10.0.215 << 'ENDSSH'
                git clone https://github.com/ClintKan/microblog_VPC_deployment.git
                bash /home/ubuntu/microblog_VPC_deployment/setup.sh
                ENDSSH
                '''
            }
        }
    }
}
