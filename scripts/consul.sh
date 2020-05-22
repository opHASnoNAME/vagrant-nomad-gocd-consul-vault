#!/bin/bash
if [ ! -f consul.installed ]; then
  
echo "### Install Consul"

# get our ip
CONSUL_IP=$(ip -f inet addr show eth1 | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")

# download and install
wget --quiet https://releases.hashicorp.com/consul/1.7.3/consul_1.7.3_linux_amd64.zip

unzip consul_1.7.3_linux_amd64.zip
sudo mv consul /usr/local/bin/
sudo groupadd --system consul
sudo useradd -s /sbin/nologin --system -g consul consul

sudo mkdir -p /var/lib/consul /etc/consul.d
sudo chown -R consul:consul /var/lib/consul /etc/consul.d
sudo chmod -R 775 /var/lib/consul /etc/consul.d

# setup systemd
sudo rm -rf /etc/systemd/system/consul.service
sudo touch /etc/systemd/system/consul.service

cat << EOF | sudo tee -a /etc/systemd/system/consul.service
# Consul systemd service unit file
[Unit]
Description=Consul Service Discovery Agent
Documentation=https://www.consul.io/
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -server -ui -bootstrap-expect=1 \
	-data-dir=/var/lib/consul \
  -node=consul-01 \
  -bind=$CONSUL_IP \
  -client=$CONSUL_IP \
	-config-dir=/etc/consul.d

ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5
Restart=on-failure
SyslogIdentifier=consul

[Install]
WantedBy=multi-user.target
EOF

# enable service
sudo systemctl daemon-reload
sudo systemctl start consul
sudo systemctl enable consul


# add consul ip to bashrc, to use consul cli
echo "export CONSUL_HTTP_ADDR=${CONSUL_IP}:8500" >> ~/.bashrc 

touch consul.installed
else 
  echo "### CONSUL already installed"
fi 
