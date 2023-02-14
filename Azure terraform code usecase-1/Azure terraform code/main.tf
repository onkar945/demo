#---------------------------
# Local declarations
#---------------------------
locals {
  # Common tags to be assigned to all resources
  tags = {
    ProjectName  = "demo-internal"
    Env          = "dev"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}

# ------------------------------------------------
# Azure Resource Group Module is called here
# ------------------------------------------------
module "rg1" {
  source     = "./modules/rg"
  az_rg_name = "testresgrp"
  tags       = local.tags
}

# ------------------------------------------------
# Azure Virtual Network Module is called here
# ------------------------------------------------
module "vnet1" {
  source                        = "./modules/vnet"
  rg_name                       = module.rg1.rg_name
  vnet_name                     = "test-vnet"
  vnet_address_space            = ["0.0.0.0/16"]
  gateway_subnet_address_prefix = ["0.0.0.0/27"]
  subnets = {
    snet-appgateway = {
      subnet_name           = "snet-appgateway"
      subnet_address_prefix = ["0.0.0.0/24"]

      nsg_inbound_rules = [
        ["appgw_rule", "104", "Inbound", "Allow", "Tcp", "65200-65535", "*", "*"],
        ["http_rule", "106", "Inbound", "Allow", "Tcp", "80", "*", "*"],
      ]
    },
    psubnet = {
      subnet_name           = "public-Subnet"
      subnet_address_prefix = ["10.10.2.0/24"]

      nsg_inbound_rules = [
        ["ssh_rule", "105", "Inbound", "Allow", "Tcp", "22", "*", "*"],
        ["http_rule", "106", "Inbound", "Allow", "Tcp", "80", "*", "*"],
      ]
    }
     privatesubnet = {
      subnet_name           = "private-Subnet"
      subnet_address_prefix = ["10.10.2.0/24"]

      nsg_inbound_rules = [
        ["ssh_rule", "105", "Inbound", "Allow", "Tcp", "22", "*", "*"],
        ["http_rule", "106", "Inbound", "Allow", "Tcp", "80", "*", "*"],
      ]
    }
  }
  tags = local.tags
}

data "azurerm_client_config" "current" {}

# ------------------------------------------------
# Azure Key Vault Module is called here
# ------------------------------------------------
module "kv" {
  source = "./modules/kv"

  kv_name = "kv813011"
  rg_name = module.rg1.rg_name
  access_policies = [
    {
      object_id               = data.azurerm_client_config.current.object_id
      certificate_permissions = ["Get", "List"]
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      storage_permissions     = []
    }
  ]
  tags = local.tags
}

# -------------------------------------------
# Azure Virtual Machine Module is called here
# -------------------------------------------
module "linux_vm" {
  source = "./modules/vm"

  rg_name              = module.rg1.rg_name
  instances_count      = 2
  virtual_machine_name = ["vm1", "vm2"]
  vm_subnet_id         = module.vnet1.subnet_ids[0]

  os_flavor                       = "linux"
  linux_distribution_name         = "ubuntu2004"
  virtual_machine_size            = "Standard_B1s"
  disable_password_authentication = false
  enable_public_ip_address        = true

  tags = local.tags
}

#--------------------------------------------------
# Retreiving first existing linux vm image
#--------------------------------------------------
data "azurerm_image" "linux1" {
  name                = "ubuntu_standard_01"
  resource_group_name = "tfbackend"
}

# ---------------------------------------------
# Build Azure Virtual Machine from Custom Image
# ---------------------------------------------
module "custom_image_vm" {
  source = "./modules/vm"

  rg_name              = module.rg1.rg_name
  instances_count      = 2
  virtual_machine_name = ["custvmlin1", "custvmlin2"]
  vm_subnet_id         = module.vnet1.subnet_ids[0]

  os_flavor                       = "linux"
  linux_distribution_name         = "ubuntu1804"
  virtual_machine_size            = "Standard_B2s"
  disable_password_authentication = false
  enable_public_ip_address        = true

  source_image_id = data.azurerm_image.linux1.id

  tags = local.tags
}

# ------------------------------------------------
# Azure Application Gateway Module is called here
# ------------------------------------------------
module "app-gateway" {
  source = "./modules/appgw"

  rg_name    = module.rg1.rg_name
  appgw_name = "demosappgw"

  # Autoscale configuration (Only available in V2 SKU)
  capacity_min = "1"
  capacity_max = "3"

  # Here application gateway will be deployed in app subnet.
  app_gw_subnet_id   = module.vnet1.subnet_ids[1]
  private_ip_address = "10.10.0.10"

  # Backend pool
  backend_address_pools = [
    {
      name = local.site1-beap
      ip_addresses = [
        module.custom_image_vm.linux_virtual_machine_ips[0],
        module.custom_image_vm.linux_virtual_machine_ips[1]
      ]
      fqdns = null
    }
  ]

  # Backend pool configuration
  backend_http_settings = [
    {
      name            = local.site1-htst
      path            = "/"
      is_https        = false
      request_timeout = 30
    }
  ]

  # Listener Configuration
  http_listeners = [
    {
      name                 = local.site1-http-listener
      ssl_certificate_name = null
    }
  ]

  # Basic App gateway routing rules currently contains HTTP Rule only.
  basic_request_routing_rules = [
    {
      name                       = local.site1-basic_request_routing_rule
      http_listener_name         = local.site1-http-listener
      backend_address_pool_name  = local.site1-beap
      backend_http_settings_name = local.site1-htst
      priority                   = "1"
    }
  ]
  tags = local.tags
}


# ---------------------------------------------
# Build Azure SQL database
# ---------------------------------------------

name_primary_database = "demodb"
resource_group = module.rg1.rg_name
primary_database_version = "demodb"
primary_database_admin = "add keyvault endpoint to secure passwords and login details"
primary_database_password = "add keyvault endpoint to secure passwords and login details"