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

variable "cluster_size" {
  default = 3
}

variable "admin_username" {
  default = "jlorich"
}

variable "admin_password" {
  default = "password.1!"
}

variable "admin_ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfUjLjP3Sy2BzV355B111HAtrvuKkQmW9m0EQMmO9z7dL42rP3HIXnZc7zMK56Uy5aeATRnFz6DqJADjJ12HrwSGBkcA6PZqJL/cY9AUZD2QJoEjufJzWntA8sbgv0OmkoeTRNPIbq1NRLzLLzi5w2fk4wbK5jkHYw5WYjz9ZFSo+mZwLsmMhqcmKv0s0C8CB9axJswCnfEh5dxUFFDSLxrCpk6FZMbmz6l4KL0abg4dP6NZq6/zwBKO/mNTIa6XmjO+gB0yAsErpvW9SEarVbM1FlJ6rjM9UhRJSnsG1AqZuOY+N/YX914rNH7H/5aiGGBOE3AcB/wG1tHANzG21d joseph@lorich.me"
}

variable "client_object_id" {
  default = "0716d8bc-6614-4bcc-bcb5-113c2218ff0d" # My object_id in Azure Active Directory
}