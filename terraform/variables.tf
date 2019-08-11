# ----------------------
# General Settings
# ----------------------
variable "name" {
  default = "demo-sf"
}

variable "prefix" {
  default = "mtcden"
}

variable "environment" {
  default = "sandbox"
}

variable "environment_short" {
  default = "sbx"
}

# ----------------------
# Service Fabric Cluster Settings
# ----------------------
variable "cluster_size" {
  default = 3
}

variable "admin_username" {
  default = "jlorich"
}

variable "admin_password" {
  default = "password.1!"
}

# Your object_id in Azure Active Directory.
# Has to be manually provided when deploying with azure-cli auth.
# Used in creating KeyVault Access Policies
variable "client_object_id" {
  default = "0716d8bc-6614-4bcc-bcb5-113c2218ff0d" 
}

# ----------------------
# API Management
# ----------------------
variable "api_publisher_name" {
  default = "Denver MTC"
}

variable "api_publisher_email" {
  default = "mtcdenver@outlook.com"
}