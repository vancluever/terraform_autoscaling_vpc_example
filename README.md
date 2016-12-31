# Multi-Tier ASG Example in Pure Terraform

This is a demo of how to create a multi-tier ASG in pure [Terraform][1].

[1]: https://terraform.io

## What's in It

The `terraform/` directory contains the basic code, utilizing external modules,
to:

 * Create a VPC with public subnets.
 * Create private subnets, matching the public subnets' availability zones, with
   NAT for outbound access.
 * ALB connected to the public subnets.
 * An ASG connected to the ALB. The instances in the launch configuration will
   find the latest hvm-ebs Amazon Linux instance, and then will bootstrap the
   instance with a test webpage based on pure user data. This setup does not
   require an AMI to be pre-built.

The config prints the ALB hostname and the security groups as outputs.

## The Modules it Uses

This example leans heavily on Terraform's [modules feature][2] to demonstrate
the power of a repeatable configuration.

[2]: https://www.terraform.io/docs/modules/index.html

The modules we make use of are:
 
 * [`terraform_aws_vpc`](https://github.com/paybyphone/terraform_aws_vpc)
 * [`terraform_aws_private_subnet`](https://github.com/paybyphone/terraform_aws_private_subnet)
 * [`terraform_aws_alb`](https://github.com/paybyphone/terraform_aws_alb)
 * [`terraform_aws_asg`](https://github.com/paybyphone/terraform_aws_asg)
 * [`terraform_aws_security_group`](https://github.com/paybyphone/terraform_aws_security_group)


## Using this Repository

All you need to use this repo is [Terraform itself][3], and `make`.

By default, the stack will deploy to `us-west-2`. To deploy it, run

```
make infrastructure
```

Valid AWS credentials will need to be available in your credential chain, either
as environment variables (ie: `AWS_ACCESS_KEY`, `AWS_SECRET_ACCESS_KEY` and
`AWS_SESSION_TOKEN`), or your credentials in your `~/.aws` directory.

### Environment variables

You can also control the build process through the following environment
variables:

 * `AWS_DEFAULT_REGION` To control the region to deploy to (default
   `us-west-2`).
 * `TF_CMD` To control the Terrafrom command (default `apply`. Change this to
   `destroy` to tear down the infrastructure).
 * `TF_DIR` To control the Terrafrom directory (default `terraform`).

## More on these Patterns

This is an evolution of a lot of other work I've done on creating a deployment
pipeline pattern that heavily relies on Terraform. For my previous work, see:

 * https://www.awsadvent.com/2016/12/06/just-add-code-fun-with-terraform-modules-and-aws/
 * https://github.com/vancluever/advent_demo
 * https://github.com/vancluever/packer-terraform-example
 * https://vancluevertech.com/2016/02/02/aws-world-detour-packer-and-terraform/

## Author and License

```
Copyright 2016 Chris Marchesi

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
