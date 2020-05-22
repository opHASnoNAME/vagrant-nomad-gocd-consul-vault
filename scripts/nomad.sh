#!/bin/bash

if [ ! -f nomad.installed ]; then
echo "### INSTALL: Nomad"

wget --quiet https://releases.hashicorp.com/nomad/0.11.1/nomad_0.11.1_linux_amd64.zip
unzip nomad_0.11.1_linux_amd64.zip
sudo chown root:root nomad 
sudo mv nomad /usr/local/bin/
nomad -autocomplete-install 
complete -C /usr/local/bin/nomad nomad
sudo mkdir --parents /opt/nomad
touch nomad.installed
nomad -v

sudo rm -rf /etc/systemd/system/nomad.service
sudo rm -rf /etc/nomad.d/nomad.hcl
sudo rm -rf /etc/nomad.d/server.hcl
sudo rm -rf /etc/nomad.d/client.hcl 

cat << EOF | sudo tee -a /etc/systemd/system/nomad.service
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
StartLimitIntervalSec=10
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo mkdir --parents /etc/nomad.d
sudo chmod 700 /etc/nomad.d
sudo touch /etc/nomad.d/nomad.hcl

cat << EOF | sudo tee -a /etc/nomad.d/nomad.hcl
datacenter = "dc1"
data_dir = "/opt/nomad"
EOF

sudo touch /etc/nomad.d/server.hcl
cat << EOF | sudo tee -a /etc/nomad.d/server.hcl
server {
  enabled = true
  bootstrap_expect = 1
}
EOF

# get our local ip
NOMAD_IP=$(ip -f inet addr show eth1 | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")

sudo touch /etc/nomad.d/client.hcl
cat << EOF | sudo tee -a /etc/nomad.d/client.hcl
client {
  enabled = true
  network_interface = "eth1"
}

bind_addr = "$NOMAD_IP" # the default

consul {
  address = "$NOMAD_IP:8500"
}
EOF

sudo systemctl daemon-reload
sudo systemctl stop nomad
sudo systemctl enable nomad
sudo systemctl start nomad
sudo systemctl status nomad

echo "export NOMAD_ADDR=http://${NOMAD_IP}:4646" >> ~/.bashrc 

else 
  echo "### NOMAD already installed"
fi 
