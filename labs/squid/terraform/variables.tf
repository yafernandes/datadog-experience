variable "creator" {}

variable "namespace" {}

variable "region" {}

variable "domain" {
    default = "azure.pipsquack.ca"
}

variable "domain-rg" {
    default = "alexf-common"
}

variable "username" {
    default = "lab"
}
