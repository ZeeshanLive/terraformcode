variable "environment" {
    type = string
}

variable "appvpc" {
    type = string
    default = "15.0.0.0/16"
}

variable "bastionsubnet" {
    type = string
    default = "15.0.1.0/24"
}

variable "appsubnet1" {
    type = string
    default = "15.0.2.0/24"
}

variable "appsubnet2" {
    type = string
    default = "15.0.3.0/24"
}



variable "dbsubnet" {
    type = string
    default = "15.0.4.0/24"
}


variable "dtvpc" {
    type = string
    default = "16.0.0.0/16"
}




variable "dtsubnet" {
    type = string
    default = "16.0.1.0/24"
}


variable appsubnetassociation{}