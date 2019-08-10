resource "azurerm_resource_group" "default" {
  name     = "${var.name}-${var.environment}-rg"
  location = "West US 2"
}

