# Service Fabric Demo
A Azure Service Fabric cluster deployment demo complete with CI/CD and Infrastructure as Code using Terraform.

## Notes
 - On first run you will have to add yourself to the access policy for keyvault as terraform has no way to know what your client ID is to create the policy dynamically unless you're running as a service principal (which I don't have currently configured to look for).  Just go to KeyVault, add an access policy for yourself, and run terraform apply again.