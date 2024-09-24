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



# Download and install Node Exporter
NODE_EXPORTER_VERSION="1.5.0"
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar xvfz node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
sudo mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64*

# Create a Node Exporter user
sudo useradd --no-create-home --shell /bin/false node_exporter

# Create a Node Exporter service file
cat << EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, start and enable Node Exporter service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Print the public IP address and Node Exporter port
echo "Node Exporter installation complete. It's accessible at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9100/metrics"

# Add Node Exporter job to Prometheus config
cat << EOF | sudo tee -a /opt/prometheus/prometheus.yml

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

# Restart Prometheus to apply the new configuration
sudo systemctl restart prometheus

echo "Node Exporter job added to Prometheus configuration. Prometheus has been restarted."