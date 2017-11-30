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
