# Define the private IP addresses for each NIC
# variable "public_private_ips" {
#  type = list(list(string))
#  default = [
#    ["20.1.0.20", "20.1.0.21", "20.1.0.22", "20.1.0.23", "20.1.0.24", "20.1.0.25", "20.1.0.26", "20.1.0.27", "20.1.0.28", "20.1.0.29"],
#    ["20.1.0.30", "20.1.0.31", "20.1.0.32", "20.1.0.33", "20.1.0.34", "20.1.0.35", "20.1.0.36", "20.1.0.37", "20.1.0.38", "20.1.0.39"],
#   ["20.1.0.40", "20.1.0.41", "20.1.0.42", "20.1.0.43", "20.1.0.44", "20.1.0.45", "20.1.0.46", "20.1.0.47", "20.1.0.48", "20.1.0.49"],
#  ]
#}

# Define the private IP addresses for each NIC with 20 IPs per list
variable "public_private_ips" {
  type = list(list(string))
  default = [
    [
      "20.1.0.20", "20.1.0.21", "20.1.0.22", "20.1.0.23", "20.1.0.24", "20.1.0.25", "20.1.0.26", "20.1.0.27", "20.1.0.28", "20.1.0.29",
      "20.1.0.30", "20.1.0.31", "20.1.0.32", "20.1.0.33", "20.1.0.34", "20.1.0.35", "20.1.0.36", "20.1.0.37", "20.1.0.38", "20.1.0.39"
    ],
    [
      "20.1.0.40", "20.1.0.41", "20.1.0.42", "20.1.0.43", "20.1.0.44", "20.1.0.45", "20.1.0.46", "20.1.0.47", "20.1.0.48", "20.1.0.49",
      "20.1.0.50", "20.1.0.51", "20.1.0.52", "20.1.0.53", "20.1.0.54", "20.1.0.55", "20.1.0.56", "20.1.0.57", "20.1.0.58", "20.1.0.59"
    ],
    [
      "20.1.0.60", "20.1.0.61", "20.1.0.62", "20.1.0.63", "20.1.0.64", "20.1.0.65", "20.1.0.66", "20.1.0.67", "20.1.0.68", "20.1.0.69",
      "20.1.0.70", "20.1.0.71", "20.1.0.72", "20.1.0.73", "20.1.0.74", "20.1.0.75", "20.1.0.76", "20.1.0.77", "20.1.0.78", "20.1.0.79"
    ]
  ]
}


# Compute local variables
locals {
  ip_addresses_per_eni = length(var.public_private_ips[0])  # Assuming all ENIs have the same number of IPs

  eni_private_ips = flatten([
    for eni_index, eni_private_ips_list in var.public_private_ips : [
      for ip_index, ip in eni_private_ips_list : {
        idx        = eni_index * local.ip_addresses_per_eni + ip_index
        eni_index  = eni_index
        private_ip = ip
      }
    ]
  ])
}

# Create 3 network interfaces with 20 private IPs each
resource "aws_network_interface" "public_eni" {
  count        = length(var.public_private_ips)
  description  = "public-eni-${count.index}"
  subnet_id    = aws_subnet.publicsubnetaz1.id
  private_ips  = var.public_private_ips[count.index]
}

# Associate EIPs with each private IP
resource "aws_eip" "public_eip" {
  for_each = {
    for val in local.eni_private_ips : "${val.eni_index}-${val.private_ip}" => val
  }

  domain                    = "vpc"
  network_interface         = aws_network_interface.public_eni[each.value.eni_index].id
  associate_with_private_ip = each.value.private_ip
}



# Define the private IP addresses for each NIC in the new range#
#variable "public_private_ips_2" {
#  type = list(list(string))
#  default = [
#    ["20.1.10.20", "20.1.10.21", "20.1.10.22", "20.1.10.23", "20.1.10.24", "20.1.10.25", "20.1.10.26", "20.1.10.27", "20.1.10.28", "20.1.10.29"],
#    ["20.1.10.30", "20.1.10.31", "20.1.10.32", "20.1.10.33", "20.1.10.34", "20.1.10.35", "20.1.10.36", "20.1.10.37", "20.1.10.38", "20.1.10.39"],
#    ["20.1.10.40", "20.1.10.41", "20.1.10.42", "20.1.10.43", "20.1.10.44", "20.1.10.45", "20.1.10.46", "20.1.10.47", "20.1.10.48", "20.1.10.49"],
#  ]
#}

# Define the private IP addresses for each NIC with 20 IPs per list
variable "public_private_ips_2" {
  type = list(list(string))
  default = [
    [
      "20.1.10.20", "20.1.10.21", "20.1.10.22", "20.1.10.23", "20.1.10.24", "20.1.10.25", "20.1.10.26", "20.1.10.27", "20.1.10.28", "20.1.10.29",
      "20.1.10.30", "20.1.10.31", "20.1.10.32", "20.1.10.33", "20.1.10.34", "20.1.10.35", "20.1.10.36", "20.1.10.37", "20.1.10.38", "20.1.10.39"
    ],
    [
      "20.1.10.40", "20.1.10.41", "20.1.10.42", "20.1.10.43", "20.1.10.44", "20.1.10.45", "20.1.10.46", "20.1.10.47", "20.1.10.48", "20.1.10.49",
      "20.1.10.50", "20.1.10.51", "20.1.10.52", "20.1.10.53", "20.1.10.54", "20.1.10.55", "20.1.10.56", "20.1.10.57", "20.1.10.58", "20.1.10.59"
    ],
    [
      "20.1.10.60", "20.1.10.61", "20.1.10.62", "20.1.10.63", "20.1.10.64", "20.1.10.65", "20.1.10.66", "20.1.10.67", "20.1.10.68", "20.1.10.69",
      "20.1.10.70", "20.1.10.71", "20.1.10.72", "20.1.10.73", "20.1.10.74", "20.1.10.75", "20.1.10.76", "20.1.10.77", "20.1.10.78", "20.1.10.79"
    ]
  ]
}


# Compute local variables for the new range
locals {
  ip_addresses_per_eni_2 = length(var.public_private_ips_2[0])  # Assuming all ENIs have the same number of IPs

  eni_private_ips_2 = flatten([
    for eni_index, eni_private_ips_list in var.public_private_ips_2 : [
      for ip_index, ip in eni_private_ips_list : {
        idx        = eni_index * local.ip_addresses_per_eni_2 + ip_index
        eni_index  = eni_index
        private_ip = ip
      }
    ]
  ])
}

# Create 3 network interfaces with 20 private IPs each
resource "aws_network_interface" "public_eni_2" {
  count        = length(var.public_private_ips_2)
  description  = "public-eni-2-${count.index}"
  subnet_id    = aws_subnet.publicsubnetaz2.id  # Ensure this subnet corresponds to the new instance
  private_ips  = var.public_private_ips_2[count.index]
}

# Output the maps of ENI private IPs
output "eni_private_ips_map" {
  value = {
    for val in local.eni_private_ips : "${val.eni_index}-${val.private_ip}" => val
  }
}

output "eni_private_ips_2_map" {
  value = {
    for val in local.eni_private_ips_2 : "${val.eni_index}-${val.private_ip}" => val
  }
}
