
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
    //   stage ('Security Check') {
    //         steps {
    //             dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
    //             dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
    //         }
    //     }
        stage ('OWASP FS SCAN') {
            environment {
                NVD-APIKEY = credentials("NVD-ApiKey")
            }
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey ${NVD-APIKEY}', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage ('Deploy') {
            steps {
                sh '''#!/bin/bash
                mkdir -p /var/lib/jenkins/.ssh/
                if [ ! -f "/var/lib/jenkins/.ssh/id_ed25519" ] && [ ! -f "/var/lib/jenkins/.ssh/id_ed25519.pub" ]; then
                    ssh-keygen -t ed25519 -f /var/lib/jenkins/.ssh/id_ed25519 -N ""
                fi
                    chmod 600 /var/lib/jenkins/.ssh/id_ed25519
                    ssh-keyscan -H 170.10.0.215 >> /var/lib/jenkins/.ssh/known_hosts
                    ssh -t -i /var/lib/jenkins/.ssh/id_ed25519 jenkins@170.10.0.215 "git clone https://github.com/ClintKan/microblog_VPC_deployment.git; bash ~./setup.sh"
                '''
            }
        }
    }
}
