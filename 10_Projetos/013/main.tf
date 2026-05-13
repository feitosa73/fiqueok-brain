terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
  tags     = { projeto = "013-ad-cloud-sync", brain_path = "10_Projetos/013" }
}

# Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-013"
  address_space       = ["10.13.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_servers         = ["10.13.1.4", "168.63.129.16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "snet-identity"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.13.1.0/24"]
}

# Segurança
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-013"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-RDP-MyIP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Tailscale"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "xxx.xxx.xxx.xxx/10"
    destination_address_prefix = "*"
  }
}

# VMs e Interfaces
locals {
  vms = {
    "dc01"   = { size = "Standard_B2ms", ip = "10.13.1.4" },
    "sync01" = { size = "Standard_B2s",  ip = "10.13.1.5" }
  }
}

resource "azurerm_public_ip" "pip_dc" {
  name                = "pip-dc-013"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nics" {
  for_each            = local.vms
  name                = "nic-${each.key}-013"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.ip
    public_ip_address_id          = each.key == "dc01" ? azurerm_public_ip.pip_dc.id : null
  }
}

resource "azurerm_network_interface_security_group_association" "assoc" {
  for_each                  = local.vms
  network_interface_id      = azurerm_network_interface.nics[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each              = local.vms
  name                  = "fiqueok-${each.key}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = each.value.size
  admin_username        = "fiqueokadmin"
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nics[each.key].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter-azure-edition"
    version   = "latest"
  }
}

# Extensão Tailscale
resource "azurerm_virtual_machine_extension" "tailscale" {
  for_each             = local.vms
  name                 = "install-tailscale"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    commandToExecute = "powershell -Command \"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi' -OutFile 'C:\\tailscale.msi'; Start-Process msiexec -ArgumentList '/i C:\\tailscale.msi /quiet' -Wait; & 'C:\\Program Files\\Tailscale\\tailscale.exe' up --authkey=${var.ts_auth_key} --unattended\""
  })
}
