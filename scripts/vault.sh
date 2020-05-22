if [ ! -f vault.installed ]; then
export VAULT_URL="https://releases.hashicorp.com/vault" 
export VAULT_VERSION="1.4.1"

curl --silent --remote-name "${VAULT_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"
curl --silent --remote-name "${VAULT_URL}/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS"
curl --silent --remote-name "${VAULT_URL}/${VAULT_VERSION}/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS.sig"

unzip vault_${VAULT_VERSION}_linux_amd64.zip
sudo chown root:root vault
sudo mv vault /usr/local/bin/
vault -autocomplete-install
complete -C /usr/local/bin/vault vault
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
sudo useradd --system --home /etc/vault.d --shell /bin/false vault


cat << EOF | sudo tee -a  /etc/systemd/system/vault.service
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitInterval=60
StartLimitIntervalSec=60
StartLimitBurst=3
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

VAULT_IP=$(ip -f inet addr show eth1 | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")

sudo mkdir --parents /etc/vault.d
sudo touch /etc/vault.d/vault.hcl
sudo chown --recursive vault:vault /etc/vault.d
sudo chmod 640 /etc/vault.d/vault.hcl

cat << EOF | sudo tee -a /etc/vault.d/vault.hcl
listener "tcp" {
  address = "$VAULT_IP:8200"
  tls_disable = 1
}

ui = true

storage "consul" {
  address = "$VAULT_IP:8500"
  path = "vault/"
}
EOF

sudo systemctl enable vault
sudo systemctl start vault
sudo systemctl status vault

echo "export VAULT_ADDR=http://${VAULT_IP}:8200" >> ~/.bashrc

touch vault.installed
else
  echo "### Vault already installed "
fi