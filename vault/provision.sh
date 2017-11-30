export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y unzip curl wget jq

export VAULT_VERSION=0.9.0
echo -e "\e[32mDownloading Vault...\e[0m"
cd /tmp/
curl -sSL "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" -o vault.zip
echo Installing Vault...
unzip vault.zip
sudo chmod +x vault
sudo mv vault /usr/bin/vault
sudo mkdir -p /etc/vault.d
sudo chmod a+w /etc/vault.d

# run as a service.
cat >/etc/systemd/system/vault.service <<'EOF'
[Unit]
Description=HashiCorp Vault
After=network.target

[Service]
ExecStart=/usr/bin/vault server -config=/vagrant/vault/vault.hcl
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# start vault
echo Starting Vault...
systemctl enable vault
systemctl start vault
sleep 3
export VAULT_ADDR=http://0.0.0.0:8200

# do not do this in production ensure sensitive data is removed or never written to file
vault init >vault-init-result.txt
awk '/Unseal Key [0-9]+: /{print $4}' vault-init-result.txt | head -3 >/etc/vault.d/vault-unseal-keys.txt
awk '/Initial Root Token: /{print $4}' vault-init-result.txt >.vault-token

cat vault-init-result.txt

# auto unseal
sleep 3 
echo Unsealing Vault...
for key in $(cat /etc/vault.d/vault-unseal-keys.txt); do
    echo using key $key
    vault unseal -address=$VAULT_ADDR $key
done

sleep 3
echo Vault status...
vault status

echo Adding the policies for the Controller...
# login
AUTH_TOKEN=$(cat .vault-token)
vault auth $AUTH_TOKEN
vault audit-enable file path=./vault_audit.log
# add the policies for the Controller
vault policy-write controller /vagrant/vault/policies/controller.hcl
vault write secret/controller/username value=controller
# create token for controller
curl --header "X-Vault-Token: $AUTH_TOKEN" --request POST --data @/vagrant/vault/policies/payload-controller.json $VAULT_ADDR/v1/auth/token/create -o /synced/controller-token.txt
