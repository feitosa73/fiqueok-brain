paulo@vault-gf-01:~$ # 1. Definir o endereço correto para a sessão atual
export VAULT_ADDR='http://127.0.0.1:8200'

# 2. Configurar o Role para TTL Infinito (Garante o estado "Ótimo" do PRJ019)
vault write auth/approle/role/prj019-ingestor \
    secret_id_ttl=0 \
    token_num_uses=0 \
    token_ttl=1h \
    token_max_ttl=3h \
    policies="policy-svc-ingestor"

# 3. Gerar o SecretID DEFINITIVO para o Vault Agent
vault write -f auth/approle/role/prj019-ingestor/secret-id
Success! Data written to: auth/approle/role/prj019-ingestor
Key                   Value
---                   -----
secret_id             64fe6d9b-5aeb-2ad8-5061-9726d15395bf
secret_id_accessor    ec61866e-2798-e2fb-f95a-56e8fa879c59
secret_id_num_uses    0
secret_id_ttl         0s
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
