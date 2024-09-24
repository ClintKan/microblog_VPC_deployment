
pipeline {
  agent any
    stages {
        stage ('Build') {
            steps {
                sh '''
                #!/bin/bash
                echo "" | echo "Checking regular updates & installing them"
                echo "" | sudo -S apt update
                echo "" | sudo -S apt upgrade -y
                echo "" | sudo -S add-apt-repository ppa:deadsnakes/ppa -y
                echo "" | sudo -S apt install python3.9 python3-pip python3.9-venv -y
                python3.9 -m venv virtual
                . virtual/bin/activate
                pip install -r requirements.txt
                '''
            }
        }
    //     stage ('Test') {
    //         steps {
    //             sh '''#!/bin/bash
    //             source venv/bin/activate
    //             py.test ./tests/unit/test_app.py --verbose --junit-xml test-reports/results.xml
    //             '''
    //         }
    //         post {
    //             always {
    //                 junit 'test-reports/results.xml'
    //             }
    //         }
    //     }
    //   stage ('OWASP FS SCAN') {
    //         steps {
    //             dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey 5a3a753b-8edc-43f5-a07f-14f53235a3e9', odcInstallation: 'DP-Check'
    //             dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
    //         }
    //     }
    //   stage ('Clean') {
    //         steps {
    //             sh '''#!/bin/bash
    //             pid=$(pgrep -f "gunicorn")
    //             pid_count=$(pgrep -f "gunicorn" | wc -l)

    //             # Check if PID is found and is valid (non-empty)
    //             if [[ $pid_count -gt 0 ]]; then
    //                 for prcs in pid_count; do
    //                 kill "$pid"
    //                 echo "Killed 'gunicorn' process with PID $pid"
    //             else
    //                 echo "No gunicorn process found to kill"
    //             fi
    //             '''
    //         }
    //     }
    //   stage ('Deploy') {
    //         steps {
    //             sh '''#!/bin/bash
    //             ssh -i ~/.ssh/id_ed25519 ubuntu@170.10.0.215 << 'ENDSSH'
    //             git clone https://github.com/ClintKan/microblog_VPC_deployment.git
    //             bash /home/ubuntu/microblog_VPC_deployment/setup.sh
    //             ENDSSH
    //             '''
    //         }
    //     }
    }
}
