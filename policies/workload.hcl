path "${mongodb_db_mount}/creds/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
