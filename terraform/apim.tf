resource "azurerm_api_management" "default" {
  name                = "${var.prefix}-${var.name}-${var.environment}-apim"
  location            = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  publisher_name      = "${var.api_publisher_name}"
  publisher_email     = "${var.api_publisher_email}"

  sku {
    name     = "Developer"
    capacity = 1
  }

  certificate {
      encoded_certificate  = "${azurerm_key_vault_certificate.client.certificate_data}"
      certificate_password = ""
      store_name           = "Root"
  }
}

resource "azurerm_api_management_api" "default" {
  name                = "demo"
  resource_group_name = "${azurerm_resource_group.default.name}"
  api_management_name = "${azurerm_api_management.default.name}"
  revision            = "1"
  display_name        = "Demo API"
  path                = ""
  protocols           = ["https"]
}

resource "azurerm_api_management_backend" "sf" {
  name                = "service-fabric-backend"
  resource_group_name = "${azurerm_resource_group.default.name}"
  api_management_name = "${azurerm_api_management.default.name}"
  protocol            = "http"
  url                 = "${azurerm_service_fabric_cluster.default.management_endpoint}"
  
  service_fabric_cluster {
      client_certificate_thumbprint    = "${azurerm_key_vault_certificate.client.thumbprint}"
      management_endpoints             = ["${azurerm_service_fabric_cluster.default.management_endpoint}"]
      max_partition_resolution_retries = 3
  }
}

resource "azurerm_api_management_api_operation" "default" {
  operation_id        = "get-me"
  api_name            = "${azurerm_api_management_api.default.name}"
  api_management_name = "${azurerm_api_management_api.default.api_management_name}"
  resource_group_name = "${azurerm_api_management_api.default.resource_group_name}"
  display_name        = "Get ME"
  method              = "GET"
  url_template        = "/users/{id}/delete"
  description         = "This can only be done by the logged in user."

  response {
    status_code = 200
  }
}