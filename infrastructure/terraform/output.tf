output "load-balancer-domain" {
  description = "The load balancer's domain"
  value       = module.load_balancer.lb_dns_name
}