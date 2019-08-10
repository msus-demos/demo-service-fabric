data "azurerm_subscription" "current" {}

resource "azurerm_service_fabric_cluster" "default" {
  name                 = "${var.name}-sf"
  resource_group_name  = "${azurerm_resource_group.default.name}"
  location             = "${azurerm_resource_group.default.location}"
  reliability_level    = "Bronze"
  vm_image             = "Linux"
  management_endpoint  = "https://example:80"

  add_on_features = [ "DnsService" ]

  node_type {
    name                 = "default"
    instance_count       = 3
    is_primary           = true
    client_endpoint_port = 19000,
    http_endpoint_port   = 19080,

    application_ports {
        start_port = 20000,
        end_port = 30000
    },

    ephemeral_ports { # possibly open client ports
        start_port = 49152,
        end_port = 65534
    }

    azure_active_directory {
      tenant_id = "${data.azurerm_subscription.current.tenant_id}"
      cluster_application_id = "${azuread_application.client.application_id}"
      client_application_id = "${azuread_application.clister.application_id}"
    }
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

  storage_image_reference {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04.0-LTS"
      version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun            = 0
    caching        = "ReadWrite"
    create_option  = "Empty"
    disk_size_gb   = 10
  }

  os_profile {
      computer_name  = "sfvm"
      admin_username = "${var.admin_username}"
      admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
      disable_password_authentication = true
      ssh_keys {
          path     = "/home/${var.admin_username}/.ssh/authorized_keys"
          key_data = "${var.admin_ssh_key}"
      }
  }

  os_profile_secrets = [
    {
      source_vault_id = "/subscriptions/55b07678-705b-45fa-904c-346637b84794/resourceGroups/exampleservicefabric-rg/providers/Microsoft.KeyVault/vaults/exampleser20180913161932"
      vault_certificates = [
        {
          certificate_url = "https://exampleser20180913161932.vault.azure.net/secrets/examplecertificate/80d472fc50414b04a10b2c172c1421c4"
          certificate_store = "My"
        }
      ]
    }
  ]

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      primary = true
      name                                   = "TestIPConfiguration"
      subnet_id                              = "${azurerm_subnet.default.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.test.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.test.*.id, count.index)}"]
    }
  }

  extension { # This extension connects vms to the cluster.
    name                 = "ServiceFabricNodeVmExt_vmNodeType0Name"
    publisher            = "Microsoft.Azure.ServiceFabric"
    type                 = "ServiceFabricNode"
    type_handler_version = "1.0"
    settings             = "{  \"certificate\": { \"thumbprint\": \"91A80082799D0E2AF20ED71CF0852E3E91168DEA\", \"x509StoreName\": \"My\" } , \"clusterEndpoint\": \"${azurerm_service_fabric_cluster.test.cluster_endpoint}\", \"nodeTypeRef\": \"${random_string.vmname.result}\", \"dataPath\": \"D:\\\\SvcFab\",\"durabilityLevel\": \"Bronze\",\"nicPrefixOverride\": \"10.0.0.0/24\"}"
  }

  # certificate {
  #   thumbprint = "91A80082799D0E2AF20ED71CF0852E3E91168DEA"
  #   thumbprint_secondary = "91A80082799D0E2AF20ED71CF0852E3E91168DEA"
  #   x509_store_name = "My"
  # }

}