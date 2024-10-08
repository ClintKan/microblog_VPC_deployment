echo “Checking regular updates & installing them”
sudo apt update
sudo apt upgrade -y

echo "Cloning the Workload 4 repo - named 'microblog_VPC_deployment'"
if [ -d "microblog_VPC_deployment" ]; then
    cd microblog_VPC_deployment
    git pull origin main
else
    git clone https://github.com/ClintKan/microblog_VPC_deployment.git
    cd microblog_VPC_deployment
fi



echo "Changing directory, to get into the cloned repo"
cd home/ubuntu/microblog_VPC_deployment

echo " "
echo “Creating a virtual environment, 'virtual'”
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.9 python3.9-venv -y
sudo apt install python3-pip -y
sudo apt install software-properties-common -y
python3.9 -m venv virtual

echo " "
echo “Activating the virtual environment”
source virtual/bin/activate

echo " "
echo “Installing nginx”
sudo apt install nginx -y

echo " "
echo "Installing dependencies from requirements.txt file"
pip install -r /home/ubuntu/microblog_VPC_deployment/requirements.txt

echo " "
echo "Installing gunicorn, pymysql, cryptography"
pip install gunicorn pymysql cryptography -y

echo " "
echo "Setting the environment variable  FLASK_APP to be equal to microblog.py"
export FLASK_APP=microblog.py

flask translate compile
flask db upgrade

gunicorn -b :5000 -w 4 microblog:app --daemon 
# --daemon is to run keep the app runnning in the background

echo " "
echo "Done..."