module "uptime_kuma" {
  source = "github.com/paliwalvimal/uptime-kuma-aws.git?ref=" # Always use `ref` to point module to a specific version or hash

  vpc_id          = "vpc-xxxxxxxxxx"
  alb_subnet_ids  = ["subnet-xxxxxxxxxx", "subnet-xxxxxxxxxx"]
  route53_zone_id = "xxxxxxxxxx"
  domain_name     = "example.com"
  db_subnet_ids   = ["subnet-xxxxxxxxxx", "subnet-xxxxxxxxxx"]
  ecs_subnet_ids  = ["subnet-xxxxxxxxxx", "subnet-xxxxxxxxxx"]
}
