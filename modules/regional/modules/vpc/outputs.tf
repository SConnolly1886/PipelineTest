output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnets" {
  value = [join(",", aws_network_acl.private_nacl.subnet_ids)]
}