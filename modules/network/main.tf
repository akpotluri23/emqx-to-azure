locals {
  vnet_name     = var.vnet_name
  public_ip_ids = [for ip in azurerm_public_ip.ip : ip.id]
  subnet_ids    = [for sn in azurerm_subnet.sn : sn.id]
  # subnets_name_id_map = {
  #   for subnet in local.azurerm_subnet.sn :
  #     subnet.name => subnet.id
  # }
}

data "azurerm_virtual_network" "existing_vnet" {
  name                = local.vnet_name
  resource_group_name = var.vnet_resource_group
}

resource "azurerm_subnet" "sn" {
  for_each = var.subnet_conf

  name                 = "${var.namespace}_${each.key}_sn"
  resource_group_name  = var.vnet_resource_group
  virtual_network_name = local.vnet_name
  address_prefixes     = [cidrsubnet(var.address_space, 8, each.value)]
}

resource "azurerm_subnet_network_security_group_association" "sn_nsg_asso" {
  subnet_id                 = local.subnet_ids[0]
  network_security_group_id = var.nsg_id
}

resource "azurerm_public_ip" "ip" {
  count = var.lb_type == "public" ? 0 : 1

  name                = "${var.namespace}_public_ip_${count.index}"
  location            = var.location
  resource_group_name = var.vnet_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.additional_tags, {
    source = "terraform"
  })
}

resource "azurerm_network_interface" "nic" {
  count = var.vm_count

  name                = "${var.namespace}_nic_${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.namespace}_ip_configuration_${count.index}"
    subnet_id                     = local.subnet_ids[0]
    private_ip_address_allocation = "Dynamic"
    
  }

  tags = merge(var.additional_tags, {
    source = "terraform"
  })
}