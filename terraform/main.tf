// Copyright 2016 Chris Marchesi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// The project path.
variable "project_path" {
  type    = "string"
  default = "vancluever/terraform_autoscaling_vpc_example"
}

// The IP space for the VPC.
variable "vpc_network_address" {
  type    = "string"
  default = "10.0.0.0/24"
}

// The IP space for the public subnets within the VPC.
variable "public_subnet_addresses" {
  type    = "list"
  default = ["10.0.0.0/26", "10.0.0.64/26"]
}

// The IP space for the private subnets within the VPC.
variable "private_subnet_addresses" {
  type    = "list"
  default = ["10.0.0.128/26", "10.0.0.192/26"]
}

// The cloud-config used to bootstrap the autoscaling instances.
variable "instance_user_data" {
  type = "string"

  default = <<EOS
#cloud-config
packages:
  - httpd

runcmd:
  - curl "http://169.254.169.254/latest/meta-data/instance-id" > "/etc/instance-id"
  - curl "http://169.254.169.254/latest/meta-data/local-ipv4" > "/etc/local-ipv4"
  - hostname "$(cat /etc/instance-id).compute.internal"
  - echo "$(cat /etc/local-ipv4) $(cat /etc/instance-id).compute.internal $(cat /etc/instance-id)" >> "/etc/hosts"
  - chkconfig httpd on
  - service httpd start
  - mkdir -p "/var/www/html/"
  - echo "Hello from $(cat /etc/instance-id)!!!" > "/var/www/html/index.html"
EOS
}

// vpc creates the VPC that will get created for our project.
module "vpc" {
  source                  = "github.com/paybyphone/terraform_aws_vpc?ref=v0.1.0"
  project_path            = "${var.project_path}"
  public_subnet_addresses = ["${var.public_subnet_addresses}"]
  vpc_network_address     = "${var.vpc_network_address}"
}

// private_subnets provides the private subnets for the VPC.
module "private_subnets" {
  source                            = "github.com/paybyphone/terraform_aws_private_subnet?ref=v0.1.1"
  nat_gateway_count                 = "${length(var.public_subnet_addresses)}"
  private_subnet_addresses          = ["${var.private_subnet_addresses}"]
  private_subnet_availability_zones = "${values(module.vpc.public_subnet_availability_zones)}"
  project_path                      = "${var.project_path}"
  public_subnet_ids                 = "${keys(module.vpc.public_subnet_availability_zones)}"
  vpc_id                            = "${module.vpc.vpc_id}"
}

// alb creates the ALB that will get created for our project.
module "alb" {
  source              = "github.com/paybyphone/terraform_aws_alb?ref=v0.1.0"
  listener_subnet_ids = ["${module.vpc.public_subnet_ids}"]
  project_path        = "${var.project_path}"
}

// autoscaling_group creates the autoscaling group that will get created for
// our project.
//
// The ALB is also attached to this autoscaling group with the default /*
// path pattern.
module "autoscaling_group" {
  source             = "github.com/paybyphone/terraform_aws_asg?ref=v0.2.0"
  alb_listener_arn   = "${module.alb.alb_listener_arn}"
  alb_service_port   = "80"
  enable_alb         = "true"
  image_filter_type  = "name"
  image_filter_value = "amzn-ami-hvm-*.*.*.*-x86_64-gp2"
  image_owner        = "amazon"
  project_path       = "${var.project_path}"
  subnet_ids         = ["${module.private_subnets.private_subnet_ids}"]
  user_data          = "${var.instance_user_data}"
}

output "alb_hostname" {
  value = "${module.alb.alb_dns_name}"
}

output "alb_security_group_id" {
  value = "${module.alb.alb_security_group_id}"
}

output "asg_instance_security_group_id" {
  value = "${module.autoscaling_group.instance_security_group_id}"
}
