variable "creator" {
    default = "kubeadm"
}
variable "namespace" {
    default = "kubeadm"
}

variable "region" {
    default = "us-east-1"
}

variable "domain" {
    default = "aws.pipsquack.ca"
}

variable "master_instance_type" {
    default = "t2.large"
}

variable "worker_instance_type" {
    default = "t2.large"
}

variable "workers_count" {
    default = 1
}