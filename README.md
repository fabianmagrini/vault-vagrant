# Vault Vagrant

## Prerequisites
- Vagrant
- Virtualbox

## Getting Started
```
cd vault-vagrant
vagrant up
```

## Vault Cheatsheet
from vault server

```
vagrant ssh vault
```

### Start

```
nohup vault server -config=/vagrant/vault/vault.hcl &
export VAULT_ADDR=http://0.0.0.0:8200
vault init
```

Vault initialized with 5 keys and a key threshold of 3. Please
securely distribute the above keys. When the vault is re-sealed,
restarted, or stopped, you must provide at least 3 of these keys
to unseal it again.

### Unseal

```
vault unseal
```

### Login
```
vault auth [root token]
```

### Enable auditing
```
vault audit-enable file path=./vault_audit.log
```

### Show mounts
```
vault mounts
```

### Add Policies
```
vault policy-write test /vagrant/vault/policies/test.hcl
```

### Writing Secrets
```
vault write secret/test/username value=testusername
```

### Create token with policy
```
vault token-create -policy=test -wrap-ttl=20m
```


### Unwrap token
from host

```
export VAULT_TOKEN=[wrapping_token]
RESPONSE=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://192.168.0.50:8200/v1/cubbyhole/response)
ACCESS_TOKEN=$(echo $RESPONSE | jq -r '.data.response | fromjson.auth.client_token')
curl -H "X-Vault-Token: $ACCESS_TOKEN" -X GET http://192.168.0.50:8200/v1/secret/test/username
```

### Renew token
from host

```
curl -H "X-Vault-Token: $ACCESS_TOKEN" -X POST http://192.168.0.50:8200/v1/auth/token/renew-self
```