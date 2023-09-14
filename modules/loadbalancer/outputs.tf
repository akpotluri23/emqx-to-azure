output "azurerm_lb_public_ip_address" {
  description = "the ip address for the azurerm_lb_public_ip resource"
  value       = var.type == "public" ? azurerm_public_ip.azlb[0].ip_address : ""
}

