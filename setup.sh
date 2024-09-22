echo "SSH-ing into AppServer EC2.."
ssh -i ~/.ssh/id_ed25519 ubuntu@170.10.8.117 << 'ENDSSH'

echo " "
echo "Now in the remote (App) server... "

echo "Running start_app script"
bash /home/ubuntu/start_app.sh

ENDSSH