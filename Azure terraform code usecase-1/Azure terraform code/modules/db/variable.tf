variable "name_primary_database" {
type= string
description = "Name of databse"
}

variable "resource_group" {
type= string
description = "Name of an Resource Group"
}

variable "location" {
 description = "Azure location for deployment"
 default     = "East US"
}

variable "primary_database_version" {
type= string
description = "Azure DB version"
}

variable "primary_database_admin" {
type= string
description = "add key vauld endpoint"
}

variable "primary_database_password" {
type= string
description = "add key vauld endpoint"
}

