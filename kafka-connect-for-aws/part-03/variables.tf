variable "vpn_to_create" {
  description = "Flag to indicate whether to create VPN"
  type        = bool
  default     = true
}

variable "vpn_to_use_spot" {
  description = "Flag to indicate whether to use a spot instance for VPN"
  type        = bool
  default     = false
}

variable "vpn_to_limit_vpn_ingress" {
  description = "Flag to indicate whether to limit ingress from the current machine's IP address"
  type        = bool
  default     = true
}

locals {
  name        = "connect-for-aws"
  region      = data.aws_region.current.name
  environment = "dev"

  vpc = {
    cidr = "10.0.0.0/16"
    azs  = slice(data.aws_availability_zones.available.names, 0, 3)
  }

  default_bucket = {
    name       = "${local.name}-${data.aws_caller_identity.current.account_id}-${local.region}"
    to_set_acl = false
  }

  vpn = {
    to_create    = var.vpn_to_create
    to_use_spot  = var.vpn_to_use_spot
    ingress_cidr = var.vpn_to_limit_vpn_ingress ? "${data.http.local_ip_address.response_body}/32" : "0.0.0.0/0"
    spot_override = [
      { instance_type : "t3.nano" },
      { instance_type : "t3a.nano" },
    ]
  }

  msk = {
    version                    = "2.8.1"
    instance_size              = "kafka.m5.large"
    ebs_volume_size            = 20
    log_retention_ms           = 604800000 # 7 days
    num_partitions             = 3
    default_replication_factor = 3
  }

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}
