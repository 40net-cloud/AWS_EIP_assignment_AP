# Terraform Logic Explanation
## 1. Defining Private IPs for Network Interfaces
We define a list of private IPs for each network interface card (NIC) using the public_private_ips variable. <br>
Each list within this variable contains 20 private IPs for a specific NIC. <br>
You can add another list for an additional interface, or increase the number of IP addresses per NIC. <br>
For example:
```
variable "public_private_ips" {
  type = list(list(string))
  default = [
    ["20.1.0.20", ..., "20.1.0.39"],  # First NIC
    ["20.1.0.40", ..., "20.1.0.59"],  # Second NIC
    ["20.1.0.60", ..., "20.1.0.79"]   # Third NIC
  ]
}
```
## 2. Computing Metadata for Private IPs
A local variable `eni_private_ips` is calculated to generate additional metadata for each private IP, such as its index and corresponding NIC index.
```
locals {
  ip_addresses_per_eni = length(var.public_private_ips[0])  # IPs per NIC (20 in this case)

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
```
## 3. Creating AWS Network Interfaces (ENIs)

We create 3 AWS ENIs (network interfaces) in this example, each with a set of 20 private IP addresses assigned. The count parameter is used to ensure that the right number of ENIs are created, and each ENI gets its respective private IP list.

```
resource "aws_network_interface" "public_eni" {
  count        = length(var.public_private_ips)
  description  = "public-eni-${count.index}"
  subnet_id    = aws_subnet.publicsubnetaz1.id
  private_ips  = var.public_private_ips[count.index]
}
```
## 4. Associating Elastic IPs (EIPs)

Elastic IPs (EIPs) are associated with each private IP address in the ENIs using the for_each loop. This allows for dynamic association of EIPs to the respective private IPs.

```
resource "aws_eip" "public_eip" {
  for_each = {
    for val in local.eni_private_ips : "${val.eni_index}-${val.private_ip}" => val
  }
  domain                    = "vpc"
  network_interface         = aws_network_interface.public_eni[each.value.eni_index].id
  associate_with_private_ip = each.value.private_ip
}
```
## 5. Creating New ENIs with Updated IP Range

We replicate the same logic for a new range of private IP addresses (public_private_ips_2) and create new ENIs and associate EIPs similarly to the original setup, ensuring each ENI is correctly populated with its respective IPs.

## 6. Testing
On the passive unit
```
diagnose debug enable
diagnose debug application awsd -1
```
On the active unit
```
execute ha failover set 1
```
