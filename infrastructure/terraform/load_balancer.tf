module "load_balancer" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "c1-c2-alb"

  load_balancer_type = "application"

  vpc_id = module.vpc.vpc_id

  #                  us-east-1a                     us-east-1b               
  subnets         = module.vpc.private_subnets
  security_groups = [module.sg.id]

  target_groups = [
    {
      name_prefix      = "c1-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {

      }
    },
    {
      name_prefix      = "c2-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        
      }
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        status_code  = 404
        content_type = "text/plain"
        message_body = "Page not found"
      }
    }
  ]

  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0
      priority                = 1

      actions = [{
        type = "forward"
        target_groups = [
          {
            target_group_index = 0
          }
        ]
      }]

      conditions = [{
        path_patterns = ["/cluster1"]
      }]
    },
    {
      http_tcp_listener_index = 0
      priority                = 2

      actions = [{
        type = "forward"
        target_groups = [
          {
            target_group_index = 1
          }
        ]
      }]

      conditions = [{
        path_patterns = ["/cluster2"]
      }]
    }
  ]
}

output "lb-id" {
  description = "The load balancer ID"
  value = module.load_balancer.lb_id
}

output "lb-domain" {
  description = "The load balancer's domain"
  value = module.load_balancer.lb_dns_name
}