# Service Fabric Demo
An Azure Service Fabric cluster deployment demo complete with CI/CD and Infrastructure as Code using Terraform.

## Notes
 - On first run you will have to add yourself to the access policy for keyvault as terraform has no way to know what your client ID is to create the policy dynamically unless you're running as a service principal (which I don't have currently configured to look for).  Just go to KeyVault, add an access policy for yourself, and run terraform apply again.
 - NOTE: Vnet support in terraform for APIm does not yet exist - this script creates the network but you must manually join it to the vnet after
 - Cert references between KeyVault and APIM are not automatic since the format is different.  Download client cert from keyvault and do the following to add a password to the key so you can import from the APIM portal:
     ```
     openssl pkcs12 -in mycert.pfx -out temp.pem
     openssl pkcs12 -export -out mycert2.pfx -in temp.pem
     ```
