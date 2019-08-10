resource "azurerm_service_fabric_cluster" "default" {
  name                = "${var.name}-sf"
  resource_group_name = "${azurerm_resource_group.default.name}"
  location            = "${azurerm_resource_group.default.location}"
  reliability_level   = "Bronze"
  vm_image            = "Linux"
  management_endpoint = "https://example:80"
  upgrade_mode        = "Automatic"

  add_on_features = ["DnsService"]

  node_type {
    name                 = "default"
    instance_count       = 3
    is_primary           = true
    client_endpoint_port = 19000
    http_endpoint_port   = 19080

    application_ports {
      start_port = 20000
      end_port   = 30000
    }

    ephemeral_ports {
      start_port = 49152 # possibly open client ports
      end_port   = 65534
    }
  }

  azure_active_directory {
    tenant_id              = "${data.azurerm_subscription.current.tenant_id}"
    cluster_application_id = "${azuread_application.client.application_id}"
    client_application_id  = "${azuread_application.cluster.application_id}"
  }

  fabric_settings {
    name = "Security"

    parameters = {
      "ClusterProtectionLevel" = "EncryptAndSign"
    }
  }

  fabric_settings {
    name = "ClusterManager"

    parameters = {
      EnableDefaultServicesUpgrade = "False"
    }
  }

  certificate {
    thumbprint           = "${azurerm_key_vault_certificate.cluster.thumbprint}"
    thumbprint_secondary = "${azurerm_key_vault_certificate.cluster.thumbprint}"
    x509_store_name      = "My"
  }
}

# Vm Scale Set
resource "azurerm_virtual_machine_scale_set" "default" {
  name                = "${var.name}-vmss"
  location            = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  upgrade_policy_mode = "Automatic"
  overprovision       = false

  sku {
    name     = "Standard_D1_v2"
    tier     = "Standard"
    capacity = "${var.cluster_size}"
  }

  storage_profile_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-with-Containers"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "sfvm"
    admin_username       = "${var.admin_username}"
    admin_password       = "${var.admin_password}"
  }

  os_profile_secrets {
    source_vault_id = "${azurerm_key_vault.cluster.id}"

    vault_certificates {
      certificate_url   = "${azurerm_key_vault.cluster.vault_uri}secrets/${azurerm_key_vault_certificate.cluster.name}/${azurerm_key_vault_certificate.cluster.version}"
      certificate_store = "My"
    }
  }

  network_profile {
    name    = "NetworkProfile"
    primary = true

    ip_configuration {
      primary                                = true
      name                                   = "IPConfiguration"
      subnet_id                              = "${azurerm_subnet.sf.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.sf.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${azurerm_lb_nat_pool.sf[0].id}"]
    }
  }

  extension {
    name                 = "ServiceFabricNodeVmExt_vmDefault" # This extension connects vms to the cluster.
    publisher            = "Microsoft.Azure.ServiceFabric"
    type                 = "ServiceFabricNode"
    type_handler_version = "1.0"

    settings = <<EOT
{
  "certificate": {
    "thumbprint": "${azurerm_key_vault_certificate.cluster.thumbprint}",
    "x509StoreName": "My"
  },
  "clusterEndpoint": "${azurerm_service_fabric_cluster.default.cluster_endpoint}",
  "nodeTypeRef": "default",
  "dataPath": "D:\\SvcFab",
  "durabilityLevel": "Bronze",
  "nicPrefixOverride": "10.0.0.0/24"
}
EOT
  }
}
