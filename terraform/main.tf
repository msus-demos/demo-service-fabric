data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "default" {
  name     = "${var.name}-${var.environment}-rg"
  location = "West US 2"
}
