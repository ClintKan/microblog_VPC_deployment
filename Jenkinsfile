
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
                sudo apt install python3.9 python3.9-venv -y
                python3.9 -m venv virtual
                pip install -r ./requirements.txt

                // cd /home/ubuntu/microblog_VPC_deployment
                // sudo add-apt-repository ppa:deadsnakes/ppa
                // sudo apt install python3-pip
                // sudo apt install software-properties-common
                // source virtual/bin/activate
                // sudo apt install nginx
                // pip install gunicorn pymysql cryptography
                // export FLASK_APP=microblog.py
                // flask translate compile
                // flask db upgrade
                // gunicorn -b :5000 -w 4 microblog:app --daemon 
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
    //             bash ./setup.sh
    //             ENDSSH
    //             '''
    //         }
    //     }
    }
}
