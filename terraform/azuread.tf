# Service Fabric Cluster
resource "azuread_application" "cluster" {
  name = "${var.name}-${var.environment}"
}

resource "azuread_service_principal" "cluster" {
  application_id = "${azuread_application.cluster.application_id}"
}

resource "random_string" "cluster_password" {
  length  = 32
  special = true
}

resource "azuread_service_principal_password" "cluster" {
  service_principal_id = "${azuread_service_principal.cluster.id}"
  value                = "${random_string.cluster_password.result}"
  end_date             = "2099-01-01T01:00:00Z"
}

# Service Fabric Client
resource "azuread_application" "client" {
  name = "${var.name}-${var.environment}"
}

resource "azuread_service_principal" "client" {
  application_id = "${azuread_application.client.application_id}"
}

resource "random_string" "client_password" {
  length  = 32
  special = true
}

resource "azuread_service_principal_password" "client" {
  service_principal_id = "${azuread_service_principal.client.id}"
  value                = "${random_string.client_password.result}"
  end_date             = "2099-01-01T01:00:00Z"
}
