output "dns_name" {
  description = "DNS Name of the master load balancer"
  value       = aws_elb.loadbalancer.dns_name
}

