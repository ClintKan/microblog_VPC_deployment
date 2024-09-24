#!/bin/bash

# Install wget if not already installed
sudo apt install wget -y

# Install Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz
tar xvfz prometheus-2.37.0.linux-amd64.tar.gz
sudo mv prometheus-2.37.0.linux-amd64 /opt/prometheus

# Create a Prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# Set ownership for Prometheus directories
sudo chown -R prometheus:prometheus /opt/prometheus

# Create a Prometheus service file
cat << EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/opt/prometheus/prometheus \
    --config.file /opt/prometheus/prometheus.yml \
    --storage.tsdb.path /opt/prometheus/data

[Install]
WantedBy=multi-user.target
EOF

# Start and enable Prometheus service
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Notice about how to edit the Prometheus yml file
echo "To edit your Prometheus yml file, check here;"
echo "/opt/prometheus/prometheus.yml or /opt/prometheus/prometheus.yml"

# Notice as to which port should be open for Prometheus
echo "To know what's listening on port 9090..."
echo "Run the command: sudo lsof -i :9090"