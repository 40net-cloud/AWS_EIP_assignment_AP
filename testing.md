# 1. variable "public_private_ips_2"

This variable defines a list of lists, where each sublist contains 20 private IP addresses. There are three sublists, representing three different network interfaces (NICs or ENIs). Each ENI will have exactly 20 IP addresses assigned to it.

## Testing
On the passive unit
```
diagnose debug enable
diagnose debug application awsd -1
```
On the active unit
```
execute ha failover set 1
```
