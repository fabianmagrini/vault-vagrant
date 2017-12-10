path "secret/controller/*" {
  capabilities = ["read"]
}

path "secret/clients/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/token/roles/controller" {
  capabilities = ["read"]
}

path "auth/approle/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

