vault token create -policy=api-proxy-policy -period=24h -format=json | jq -r .auth.client_token
hvs.CAESINLtw0ByJ1L8VCG7Z_O2yC4wF_<REDACTED_SECRET>JlZ0xsMlRSNEZrZm1WZVE


sudo mkdir -p /var/lib/shadow-api echo "hvs.CAESINLtw0ByJ1L8VCG7Z_O2yC4wF_<REDACTED_SECRET>JlZ0xsMlRSNEZrZm1WZVE" | sudo tee /var/lib/shadow-api/vault_token > /dev/null sudo chmod 600 /var/lib/shadow-api/vault_token




paulo@vault-gf-01:~$ # Gere o token com a política correta e nome de serviço
vault token create \
  -policy="api-proxy-policy" \
  -display-name="svc-shadow-api" \
  -ttl="720h"
Key                  Value
---                  -----
token                <REDACTED_SECRET><REDACTED_SECRET>VHJKUDA3aXZPSGt2NEhtUzVnSmQ
token_accessor       h9LEIdhrKf2enoUbFMAh42XA
token_duration       720h
token_renewable      true
token_policies       ["api-proxy-policy" "default"]
identity_policies    []
policies             ["api-proxy-policy" "default"]
paulo@vault-gf-01:~$



# Você precisará de sudo porque o diretório /var/lib/ costuma ser restrito
sudo mkdir -p /var/lib/shadow-api
echo "<REDACTED_SECRET><REDACTED_SECRET>VHJKUDA3aXZPSGt2NEhtUzVnSmQ" | sudo tee /var/lib/shadow-api/vault_token
sudo chmod 600 /var/lib/shadow-api/vault_token
