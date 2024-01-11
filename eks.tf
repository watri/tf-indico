module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.21.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.25"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs = [
    var.vpn
  ]

  vpc_id     = module.vpc-indico.vpc_id
  subnet_ids = module.vpc-indico.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    DEV = {
      cluster_version = "1.25"
      ami_type        = "AL2_x86_64"
      instance_types  = ["t3.medium"]

      create_launch_template  = false
      launch_template_name    = aws_launch_template.lt_1.name
      launch_template_version = aws_launch_template.lt_1.default_version

      max_size = 1
      min_size = 1

      tags = {
        Env = "dev_amd64"
      }

      labels = {
        Environment = "dev_amd64"
      }
    }
  }

  node_security_group_additional_rules = {
    egress_all = {
      description      = "Outbound request to ALL"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    ingress_self = {
      description = "Inbound All trafic - self"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    webhook_admission_inbound = {
      description                   = "Cluster API to Node Groups (webhook admission)"
      protocol                      = "tcp"
      from_port                     = "8443"
      to_port                       = "8443"
      type                          = "ingress"
      source_cluster_security_group = true
    }
    metrics_server_allow_from_control_plane = {
      description                   = "Allow access from control plane to metrics server webhook"
      protocol                      = "tcp"
      from_port                     = "4443"
      to_port                       = "4443"
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  tags = {  
    Environment = var.cluster_name
  }

  aws_auth_users            = var.map_users
  aws_auth_accounts         = var.aws_account
  manage_aws_auth_configmap = true
}

resource "aws_launch_template" "lt_1" {
  name_prefix = "DEV-"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 50
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [
    module.eks.node_security_group_id
  ]

  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "DEV"
    }
  }
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name      = var.cluster_name
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.16.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
  service_account_role_arn = module.iam_eks_role.iam_role_arn
}

