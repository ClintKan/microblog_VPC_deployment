# C5 DEPLOYMENT WORKLOAD 4


---


## <ins> OBJECTIVE</ins>

While in workload 3 (see snippet of it here), it was about manually deploying a webapp (plus doing unit testing) using a Jenkins multibranch CI/CD pipeline, in this workload 4, we structure out the cloud infrastructure; from VPCs, availability zones, nat gateway, VPC peering CIDR blocks, subnets, route tables.

## Steps Taken

1. Application source files were cloned onto my workstation and then pushed to my GitHub (with a specified repo name - without the quotes - "microblog_VPC_deployment")

2. Created an AWS account along with default infrastructure components like; VPC, default region, availability zone, CIDR block, NAT gateway and default subnet. It is within this that an EC2 (t3.medium Ubuntu Linux server) was setup to be used for the running of the CI/CD pipeline.

3. On the above Jenkins EC2 server, Jenkins was installed on it and the following security port configurations aka Secur; 22 for SSH, 8080 for Jenkins done.

4. A second VPC was then created, with one availability zone, one public subnet and one private subnet, a NAT Gateway in 1 AZ but with DNS hostnames and DNS resolution should be selected.

5. Three EC2s were then created as follows;

   - One for the Web Server - Created in a public subnet with a security group opening only ports; 22 (SSH) & 80 (HTTP), this is the server that hosted the web app. On it, was 3 WebApp stac
     tools were installed; Ngnix, Flask and HTML needed collaboratively to serve, process and present web content. Nginx serves as the web server and reverse proxy, managing
     client requests and delivering static files. Flask is a lightweight Python framework that handles the backend logic and routing for dynamic content. HTML structures the web
     pages, defining how content is displayed. Together, they enable the creation of interactive and responsive web applications.

   - One for the Application Server - Created in a private subnet with a security group opening only ports; 22 (SSH) & 5000 (this port was opened to be used for serving the web app
     to Ngnix serving as a reverse proxy). Additionally, the application server is the hub of all the webapp's files - that got added by executing the start_app.sh that got
     invoked by executing the setup.sh from the Web Server.

   - One for the Monitoring Server - Created in a public subnet with a security group opening only ports; 22 (SSH) & 3000 (Grafana) & 9090 (Prometheus). This is a server that was
     setup for monitoring purposes of the (aforementioned) servers and the webapp.
     
     
7. CI/CD Pipeline configuration was then done, not so different from the one in workload 3 - within the Jenkins file as follows (reference it here to follow along). Below I :

   **(a.) Build Stage:**
   In this stage, the focus was to setup and prepare ther server to ready it for the cloning of the Github repo


   **(b.) Test Stage:**
   This stage was exactly similar to the workload 3's

   **(c.) OWAS FS SCAN Stage:**
   This stage was exactly similar to the workload 3's
   
   **(d.) Deploy Stage:**
   This is where the the pipeline (the Jenkins user from the Jenkins EC2) remotes into the WebServer (via SSH) and executes the following commands below

Below is an expansion on what the commands do/invoke;
   - 


   
9. In the AWS console, create a custom VPC with one availability zome, a public and a private subnet.  There should be a NAT Gateway in 1 AZ and no VPC endpoints.  DNS hostnames and DNS resolution should be selected.

10. Navigate to subnets and edit the settings of the public subet you created to auto assign public IPv4 addresses.

11. In the Default VPC, create an EC2 t3.medium called "Jenkins" and install Jenkins onto it.  

12. Create an EC2 t3.micro called "Web_Server" In the PUBLIC SUBNET of the Custom VPC, and create a security group with ports 22 and 80 open.  

13. Create an EC2 t3.micro called "Application_Server" in the PRIVATE SUBNET of the Custom VPC,  and create a security group with ports 22 and 5000 open. Make sure you create and save the key pair to your local machine.

14. SSH into the "Jenkins" server and run `ssh-keygen`. Copy the public key that was created and append it into the "authorized_keys" file in the Web Server. 

IMPORTANT: Test the connection by SSH'ing into the 'Web_Server' from the 'Jenkins' server.  This will also add the web server instance to the "list of known hosts"

Question: What does it mean to be a known host?

8. In the Web Server, install NginX and modify the "sites-enabled/default" file so that the "location" section reads as below:
```
location / {
proxy_pass http://<private_IP>:5000;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```
IMPORTANT: Be sure to replace `<private_IP>` with the private IP address of the application server. Run the command `sudo nginx -t` to verify. Restart NginX afterward.

9. Copy the key pair (.pem file) of the "Application_Server" to the "Web_Server".  How you choose to do this is up to you.  (Best practice would be to SCP from your local machine into the Jenkins server but if not, it is possible to nano a new file and copy/paste the contents of the .pem file into it.  MAKE SURE TO INCLUDE EVERYTHING FROM -----BEGIN RSA PRIVATE KEY----- to -----END RSA PRIVATE KEY----- including a new line afterwards if you chose this route)

IMPORTANT: Test the connection by SSH'ing into the "Application_Server" from the "Web_Server".

10. Create scripts.  2 scripts are required for this Workload and outlined below:

a) a "start_app.sh" script that will run on the application server that will set up the server so that has all of the dependencies that the application needs, clone the GH repository, install the application dependencies from the requirements.txt file as well as [gunicorn, pymysql, cryptography], set ENVIRONMENTAL Variables, flask commands, and finally the gunicorn command that will serve the application IN THE BACKGROUND

b) a "setup.sh" script that will run in the "Web_Server" that will SSH into the "Application_Server" to run the "start_app.sh" script.

(HINT: run the scripts with "source" to avoid issues)

Question: What is the difference between running scripts with the source command and running the scripts either by changing the permissions or by using the 'bash' interpreter?

IMPORTANT: Save these scripts in your GitHub Respository in a "scripts" folder.

11. Create a Jenkinsfile that will 'Build' the application, 'Test' the application by running a pytest (you can re-use the test from WL3 or challenge yourself to create a new one), run the OWASP dependency checker, and then "Deploy" the application by SSH'ing into the "Web_Server" to run "setup.sh" (which would then run "start_app.sh").

IMPORTANT/QUESTION/HINT: How do you get the scripts onto their respective servers if they are saved in the GitHub Repo?  Do you SECURE COPY the file from one server to the next in the pipeline? Do you C-opy URL the file first as a setup? How much of this process is manual vs. automated?

Question 2: In WL3, a method of "keeping the process alive" after a Jenkins stage completed was necessary.  Is it in this Workload? Why or why not?

12. Create a MultiBranch Pipeline and run the build. IMPORTANT: Make sure the name of the pipeline is: "workload_4".  Check to see if the application can be accessed from the public IP address of the "Web_Server".

13. If all is well, create an EC2 t3.micro called "Monitoring" with Prometheus and Grafana and configure it so that it can collect metrics on the application server.

14. Document! All projects have documentation so that others can read and understand what was done and how it was done. Create a README.md file in your repository that describes:

	  a. The "PURPOSE" of the Workload,

  	b. The "STEPS" taken (and why each was necessary/important),
    
  	c. A "SYSTEM DESIGN DIAGRAM" that is created in draw.io (IMPORTANT: Save the diagram as "Diagram.jpg" and upload it to the root directory of the GitHub repo.),

	  d. "ISSUES/TROUBLESHOOTING" that may have occured,

  	e. An "OPTIMIZATION" section for that answers the questions: What are the advantages of separating the deployment environment from the production environment?  Does the infrastructure in this workload address these concerns?  Could the infrastructure created in this workload be considered that of a "good system"?  Why or why not?  How would you optimize this infrastructure to address these issues?

    f. A "CONCLUSION" statement as well as any other sections you feel like you want to include.
