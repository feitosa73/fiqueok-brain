output "rdp_dc01" { value = "mstsc /v:${azurerm_public_ip.pip_dc.ip_address}" }
output "ip_sync01" { value = "10.13.1.5 (Acesso via Tailscale)" }