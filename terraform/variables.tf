variable "public_subnets" {
  type = list(string)
  default = [ "subnet-07e8c1e0a34929361", "subnet-08cb53a8ec3966329" ]
}

variable "vpc_id" {
    type = string
    default = "vpc-0476f10dd1d281ca2"
}

variable "app_name" {
    type = string
    default = "n8n"
}