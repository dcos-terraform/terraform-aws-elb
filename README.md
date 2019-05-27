[![Build Status](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-aws-elb/job/master/badge/icon)](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-aws-elb/job/master/)
AWS ELB
============
This module create AWS ELBs for DC/OS

EXAMPLE
-------

```hcl
module "dcos-elbs" {
  source  = "terraform-dcos/elb/aws"
  version = "~> 0.1.0"

  cluster_name = "production"

  subnet_ids = ["subnet-12345678"]
  security_groups_external_masters = ["sg-12345678"]
  security_groups_external_public_agents = ["sg-12345678"]
  master_instances = ["i-00123456789e960f8"]
  public_agent_instances = ["i-00123456789e960f8"]

  aws_external_masters_acm_cert_arn = "arn:aws:acm:us-east-1:123456789123:certificate/ooc4NeiF-1234-5678-9abc-vei5Eeniipo4"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster\_name | Name of the DC/OS cluster | string | n/a | yes |
| instances | List of instance IDs | list | n/a | yes |
| subnet\_ids | List of subnet IDs created in this network | list | n/a | yes |
| additional\_listener | List of additional listeners | list | `<list>` | no |
| connection\_draining | Enable connection draining | string | `"false"` | no |
| cross\_zone\_load\_balancing | Enable cross-zone load balancing | string | `"true"` | no |
| elb\_name\_format | Printf style format for naming the ELB. Gets truncated to 32 characters. (input cluster_name) | string | `"load-balancer-%s"` | no |
| health\_check | Health check definition. | map | `<map>` | no |
| https\_acm\_cert\_arn | ACM certifacte to be used. | string | `""` | no |
| idle\_timeout | Time in seconds the connection is allowed to be idle | string | `"60"` | no |
| internal | This ELB is internal only | string | `"false"` | no |
| listener | List of listeners. By default HTTP and HTTPS are set. If set it overrides the default listeners. | list | `<list>` | no |
| security\_groups | Security Group IDs to use | list | `<list>` | no |
| tags | Add custom tags to all resources | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| dns\_name | DNS Name of the master load balancer |

