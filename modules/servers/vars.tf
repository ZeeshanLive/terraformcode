variable "environment" {
    type = string
}


variable "appamiid" {
    type = string
    default = "ami-04e90e551afdc4b7c"
}


variable "appinstancesize" {
    type = string
    default = "t2.micro"
}


variable appsubnets{}

variable appvpc{}

variable vpnami{
    type = string
    default = "ami-05e16100b6f337dda"
}

variable vpninstancesize {
    type = string
    default = "t2.micro"
}

variable vpnsubnet{}



variable dbami{
    type = string
    default = "ami-05e16100b6f337dda"
}

variable dbinstancesize {
    type = string
    default = "t2.micro"
}

variable dbsubnet{}


variable dtami{
    type = string
    default = "ami-05e16100b6f337dda"
}

variable dtinstancesize {
    type = string
    default = "t2.micro"
}

variable dtsubnet{}