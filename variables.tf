variable "region" {
  default = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "vpc cidr"
  type        = string
  default     = "10.250.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-southeast-3a", "ap-southeast-3b", "ap-southeast-3c"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.250.1.0/24", "10.250.2.0/24", "10.250.3.0/24"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.250.4.0/24", "10.250.5.0/24", "10.250.6.0/24"]
}

variable "cluster_name" {
  default = "indico-eks"
}

variable "aws_account" {
  type    = list(string)
  default = ["222222222222"]
}

variable "vpn" {
  default = "0.0.0.0/32"
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::682624757233:user/admin-kubernetes"
      username = "admin-kubernetes"
      groups   = ["system:masters"]
    },
  ]
}

