/**
 * [![Build Status](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-aws-elb/job/master/badge/icon)](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-aws-elb/job/master/)
 * AWS ELB
 * ============
 * This module create AWS ELBs for DC/OS
 *
 * EXAMPLE
 * -------
 *
 *```hcl
 * module "dcos-elbs" {
 *   source  = "terraform-dcos/elb/aws"
 *   version = "~> 0.3.0"
 *
 *   cluster_name = "production"
 *
 *   subnet_ids = ["subnet-12345678"]
 *   security_groups_external_masters = ["sg-12345678"]
 *   security_groups_external_public_agents = ["sg-12345678"]
 *   master_instances = ["i-00123456789e960f8"]
 *   public_agent_instances = ["i-00123456789e960f8"]
 *
 *   aws_external_masters_acm_cert_arn = "arn:aws:acm:us-east-1:123456789123:certificate/ooc4NeiF-1234-5678-9abc-vei5Eeniipo4"
 * }
 *```
 */

provider "aws" {
  version = ">= 2.58"
}

// Only 32 characters allowed for name. So we have to use substring
locals {
  elb_name = format(var.elb_name_format, var.cluster_name)

  default_listeners = [
    {
      instance_port     = 80
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    },
    {
      instance_port      = 443
      instance_protocol  = var.https_acm_cert_arn == "" ? "tcp" : "https"
      lb_port            = 443
      lb_protocol        = var.https_acm_cert_arn == "" ? "tcp" : "https"
      ssl_certificate_id = var.https_acm_cert_arn
    },
  ]
}

resource "aws_elb" "loadbalancer" {
  name = substr(
    local.elb_name,
    0,
    length(local.elb_name) >= 32 ? 32 : length(local.elb_name),
  )

  subnets         = var.subnet_ids
  security_groups = var.security_groups

  internal = var.internal
  dynamic "listener" {
    for_each = coalescelist(
      var.listener,
      concat(local.default_listeners, var.additional_listener),
    )
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      instance_port      = listener.value.instance_port
      instance_protocol  = listener.value.instance_protocol
      lb_port            = listener.value.lb_port
      lb_protocol        = listener.value.lb_protocol
      ssl_certificate_id = lookup(listener.value, "ssl_certificate_id", null)
    }
  }
  dynamic "health_check" {
    for_each = [var.health_check]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      healthy_threshold   = health_check.value.healthy_threshold
      interval            = health_check.value.interval
      target              = health_check.value.target
      timeout             = health_check.value.timeout
      unhealthy_threshold = health_check.value.unhealthy_threshold
    }
  }
  instances                 = var.instances
  cross_zone_load_balancing = var.cross_zone_load_balancing
  idle_timeout              = var.idle_timeout
  connection_draining       = var.connection_draining

  tags = merge(
    var.tags,
    {
      "Name"    = format(var.elb_name_format, var.cluster_name)
      "Cluster" = var.cluster_name
    },
  )
}

