provider "aws" {
  version = "~> 3.0"
  region  = "eu-west-2"
}

module "networking" {
  source = "../modules/network"
  environment = "test"
  appvpc = "10.0.0.0/16"
  bastionsubnet = "10.0.1.0/24"
  appsubnet1 = "10.0.2.0/24"
  appsubnet2 = "10.0.3.0/24"
  dbsubnet = "10.0.4.0/24"
  dtvpc = "11.0.0.0/16"
  dtsubnet = "11.0.1.0/24"
  appsubnetassociation=module.networking.AppServerSubnets
  
}

module "servers" {
  source = "../modules/servers"
  environment = "test"
  keyname = "idv-test-key"
  appvpc= module.networking.appvpc
  appsubnets=module.networking.AppServerSubnets
  appamiid = "ami-0ed417ef057137c75"
  appinstancesize = "t2.micro"
  vpnami = "ami-05e16100b6f337dda"
  vpninstancesize = "t2.micro"
  vpnsubnet = module.networking.vpnsubnet
  vpneip = module.networking.vpneip
  dbami = "ami-05e16100b6f337dda"
  dbinstancesize = "t2.micro"
  dbsubnet = module.networking.dbsubnet
  dtami = "ami-05e16100b6f337dda"
  dtinstancesize = "t2.micro"
  dtsubnet = module.networking.dtsubnet
}
output "az" {
  value = module.networking.azs
}
output "subnets" {
  value = module.networking.AppServerSubnets
}

output "test" {
  value = module.networking.dtsubnet
}