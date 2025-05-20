resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_1.id   
  depends_on    = [aws_internet_gateway.igw]
}






# resource "aws_network_acl_association" "nat" {
#   subnet_id      = aws_subnet.public_subnet_1.id
#   network_acl_id = aws_network_acl.nat.id
# }

# resource "aws_network_acl" "nat" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name = "nat"
#   }
# }

# # Inbound rules
# resource "aws_network_acl_rule" "inbound_https" {
#   network_acl_id = aws_network_acl.nat.id
#   rule_number    = 100
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = aws_vpc.vpc.cidr_block
#   from_port      = 443
#   to_port        = 443
# }

# resource "aws_network_acl_rule" "inbound_ssh" {
#   network_acl_id = aws_network_acl.nat.id
#   rule_number    = 50
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"  # Replace with your IP range if you want to restrict access
#   from_port      = 22
#   to_port        = 22
# }

# resource "aws_network_acl_rule" "inbound_ephemeral" {
#   network_acl_id = aws_network_acl.nat.id
#   rule_number    = 200
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "92.11.193.226/32"  # Replace with your public IP
#   from_port      = 1024
#   to_port        = 65535
# }

# # Outbound rules
# resource "aws_network_acl_rule" "outbound_https" {
#   network_acl_id = aws_network_acl.nat.id
#   rule_number    = 300
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "92.11.193.226/32"  # Replace with your public IP
#   from_port      = 443
#   to_port        = 443
# }

# resource "aws_network_acl_rule" "outbound_ephemeral" {
#   network_acl_id = aws_network_acl.nat.id
#   rule_number    = 400
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = aws_vpc.vpc.cidr_block
#   from_port      = 1024
#   to_port        = 65535
# }


# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name = "main"
#   }
# }

# resource "aws_route_table_association" "public" {
#   subnet_id      = tolist(aws_vpc.vpc.public_subnets)[0]
#   route_table_id = aws_route_table.public.id
# }


# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = tolist(aws_vpc.vpc.public_subnets)[0]    
#   depends_on    = [aws_internet_gateway.main]
# }

# resource "aws_route" "public" {
#   route_table_id         = aws_vpc.vpc.public_route_table_ids[0]
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_vpc.vpc.igw_id
    # }