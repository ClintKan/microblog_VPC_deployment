# C5 DEPLOYMENT WORKLOAD 4


---


## <ins> OBJECTIVE</ins>

While in workload 3 (see snippet of it here), it was about manually deploying a webapp (plus doing unit testing) using a Jenkins multibranch CI/CD pipeline, in this workload 4, we structure out the cloud infrastructure; from VPCs, availability zones, nat gateway, VPC peering CIDR blocks, subnets, route tables.

## Steps Taken

1. Application source files were cloned onto my workstation and then pushed to my GitHub (with a specified repo name - without the quotes - "microblog_VPC_deployment")

2. Created an AWS account along with default infrastructure components like; VPC, default region, availability zone, CIDR block, NAT gateway and default subnet. It is within this that an EC2 (t3.medium Ubuntu Linux server) was setup to be used for the running of the CI/CD pipeline.

3. On the above Jenkins EC2 server, Jenkins was installed on it and the following security port configurations aka Secur; 22 for SSH, 8080 for Jenkins done.

4. A second (custom) VPC was then created, with one availability zone, one public subnet and one private subnet, a NAT Gateway in 1 AZ but with DNS hostnames and DNS resolution should be selected.

5. Three EC2s were then created as follows;

   - **One for the Web Server;** - Created in a public subnet with a security group opening only ports; 22 (SSH) & 80 (HTTP), this is the server that hosted the web app. On it, the following 3 WebApp stack
     tools were installed; Ngnix, Flask and HTML needed collaboratively to serve, process and present web content. Nginx serves as the web server and reverse proxy (more on this below), managing
     client requests and delivering static files. Flask is a lightweight Python framework that handles the backend logic and routing for dynamic content. HTML structures the web
     pages, defining how content is displayed. Together, they enable the creation of interactive and responsive web applications.

     Nginx was made to act as a reverse proxy server by updating the nginx config file located in; /etc/nginx/sites-enabled/default, replacing the location part in the file with the lines below;
     
     	   ```
     	   location / {
	   proxy_pass http://<application-server's-private_IP>:5000;
	   proxy_set_header Host $host;
	   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	   }

	   ```
    
    	   These lines basically forced Nginx to listed to the Application server's private IP via port 5000, and then redirect and serve that to it's (the Web server's) IP address at port 80.

    <ins>**Note:**</ins> To confirm the changes made are valid, run the command ``` sudo nginx -t ```.

    While not related to the application, but rather for monitoring purposes, Node Exporter a monitoring tool was installed on the Web server as well so as to scrape metrics and serve them to the Monitoring
    server's Prometheus and Grafana (more on this below).


   - One for the Application Server - Created in a private subnet with a security group opening only ports; 22 (SSH) & 5000 (this port was opened to be used for serving the web app
     to Ngnix serving as a reverse proxy). Additionally, the application server is the hub of all the webapp's files - that got added by executing the start_app.sh that got
     invoked by executing the setup.sh from the Web Server.

   - One for the Monitoring Server - Created in a public subnet with a security group opening only ports; 22 (SSH) & 3000 (Grafana) & 9090 (Prometheus). This is a server that was
     setup for monitoring purposes of the (aforementioned) servers and the webapp.
     
     
7. VPC Peering was setup so that the default and Custom VPCs can communicate on a private network level without the getting on the internet. Route tables in both VPCs had to be associated with each other's
CIDR Blocks so that the traffic can be redirected properly.

8. CI/CD Pipeline configuration was then done, not so different from the one in workload 3 - within the Jenkins file as follows (reference it here to follow along):

   **(a.) Build Stage:**
   In this stage, the focus was to setup and prepare the server to ready it for the cloning of the Github repo and the test stage to be executed on the server's terminal.

   **(b.) Test Stage:**
   This stage was exactly similar to the workload 3's. The test, done by running the test_app.py, was done in a way of calling up 3 html pages - once the microblog app has been launched in the virtual evnironment,
   and if they are all up and running then it passed.

   **(c.) OWAS FS SCAN Stage:**
   This stage was exactly similar to the workload 3's but with added security hiding the NVD API key used to scan the application's source files. This time the key was added in Jenkins' GUI security feature of
   inputing credentials (_see code lines below environment portion_) that then get passed during the running of code. Below are the configurations done in the Jenkins GUI and the code lines.


   <div align="center">
	<img width="1461" alt="Dependecy check" src="https://github.com/user-attachments/assets/c3d78437-1506-4802-9bfc-1155337e7da1">
   </div>

   
   ```
      stage ('OWASP FS SCAN') {
   	environment {
   		NVD_APIKEY = credentials("NVD-ApiKey")
   	}
   	steps {
   	   dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey ${NVD_APIKEY}', odcInstallation: 'DP-Check'
           dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
   	}
      }
   ```
   

   **(d.) Deploy Stage:**
   This is where the the pipeline (_the Jenkins user from the Jenkins EC2_) remotes into the WebServer (via SSH). But prior to that, it creates a SSH key that it uses to SSH into the Webserver - there is a
   manual process here of adding the created private key to the Webserver prior to the executing of this stage - and then when in Webserver, this github repo was cloned to only execute the **_setup.sh_** script.

   ```
      mkdir -p /var/lib/jenkins/.ssh/
      if [ ! -f "/var/lib/jenkins/.ssh/id_ed25519" ] && [ ! -f "/var/lib/jenkins/.ssh/id_ed25519.pub" ]; then
   	  ssh-keygen -t ed25519 -f /var/lib/jenkins/.ssh/id_ed25519 -N ""
      fi
      chmod 600 /var/lib/jenkins/.ssh/id_ed25519
      ssh-keyscan -H 170.10.0.215 >> /var/lib/jenkins/.ssh/known_hosts
      ssh -t -i /var/lib/jenkins/.ssh/id_ed25519 ubuntu@170.10.0.215 "git clone https://github.com/ClintKan/microblog_VPC_deployment.git; bash /home/ubuntu/microblog_VPC_deployment/setup.sh"
   ```

   Below is a how the Jenkins' CI/CD pipeline would look if successful.

   <div align="center">
	<>
   </div>


   Furthermore is what happens once the **_setup.sh_** is run. In the setup script is the invokation to remote (via SSH) into the Application server to then execute/run the **_start_app.sh_** script. On running the
   **_start_app.sh_**, this repo is then cloned again on to the Application server, a virtual environment created, the app's re-requisites for smooth runnning installed and the then the app itself launched.
   It is successful when the app is accessible via the public IP address of the Web Server - why? see


      <div align="center">
	      <img width="1461" alt="Microblog App" src="https://https://github.com/user-attachments/assets/645cc231-7e65-4aa7-9609-331856a2dbaa">
      </div>


---


## <ins> TROUBLESHOOTING STEPS</ins>

a.) The inability to have cross communication between the VPCs. This led to the use of the VPC Peering option that helps communicate on a private network level. Additionally, acceptance of the request to connect to each other and then the association of the CIDR blocks turned out to be a key step or else the VPC peering didn't work by itself.
b.) The pytest requirement in the requirements.txt file was missing and therefore failing to pass the Test stage s the command **_py.test_** was not recognized. But once added all was good.
c.) The execution of subsequent commands in the server (EC2) that has been SSH'd into. While SSH would work, without adding ``` "the-commands-to-execute-while-in-the-server-you-ssh-into" ``` on the same line as the SSH 
command the commands would be executed in the initial server and not the destination server that's been SSH'd into. See the **_Deploy stage_** and the **_setup.sh_** script for more here
d.) The Deploy stage kept failing with an error of permission denied (public key). This was due to the fact that the Jenkins user was using ubuntu user's private key - even chmod 600 "the-private-key-file-path" didn't work. upon research and disscusions with colleagues; Shafee & Jon Wang, it was made clear that another user can't use another user's key even though you change the permissions on it. This lead to the addition of the
lines below so that Jenkins creates a key and uses that to log into the Application server;
``` 
      mkdir -p /var/lib/jenkins/.ssh/
      if [ ! -f "/var/lib/jenkins/.ssh/id_ed25519" ] && [ ! -f "/var/lib/jenkins/.ssh/id_ed25519.pub" ]; then
   	  ssh-keygen -t ed25519 -f /var/lib/jenkins/.ssh/id_ed25519 -N ""
      fi
      chmod 600 /var/lib/jenkins/.ssh/id_ed25519
      ssh-keyscan -H 170.10.0.215 >> /var/lib/jenkins/.ssh/known_hosts

```

---


## <ins> OPTIMIZATION STEPS</ins>


---


## <ins> CONCLUSION STEPS</ins>


---


## <ins> REFERENCES & HONEROABLE MENTIONS FROM COLLEAGUES</ins>

Being a learning process, there were multiple resources and program colleagues that I consulted to be able to put this together and in this section I would like to list them out;

**Colleagues:** Shafee, Carl Gordon, Jon Wang

**Web links:**
- https://plugins.jenkins.io/dependency-check-jenkins-plugin/
- https://stackoverflow.com/questions/18522647/run-ssh-and-immediately-execute-command
- https://github.com/ClintKan/microblog_EC2_deployment (Workload 3, since this is deployment step up of it).
-

**WebApps:** ChatGPT, chatgpt.com
