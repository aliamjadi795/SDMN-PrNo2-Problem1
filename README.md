# Question 1 – Routing After Removing the Router Namespace

After deleting the router namespace and its links to `br1` and `br2` (Figure 2), the two subnets become isolated. This is because Linux bridges operate only at **Layer 2** of the OSI model and therefore cannot route packets between different IP subnets.

To restore connectivity, the routing functionality can be moved from the dedicated router namespace to the **root namespace** (the host). The host then acts as the router between the two LANs.

## Required configuration

1. **Assign gateway IP addresses in the root namespace**

   The gateway IP addresses previously assigned to the router namespace should be assigned to the root namespace interfaces connected to each bridge:

   - `172.0.0.1/24` for the interface connected to **br1**
   - `10.10.0.1/24` for the interface connected to **br2**

   These addresses become the default gateways for the two subnets.

2. **Enable IP forwarding**

   The Linux kernel in the root namespace must be configured to forward IPv4 packets (`net.ipv4.ip_forward=1`).

3. **Allow forwarding through the firewall (if applicable)**

   If `iptables`/`nftables` filtering is enabled, the **FORWARD** chain must allow packets to pass between the interfaces connected to `br1` and `br2`. If the forwarding policy is already `ACCEPT`, no additional firewall rules are required.

4. **Default routes**

   No changes are required to the nodes' default routes because the gateway IP addresses remain the same (`172.0.0.1` and `10.10.0.1`), only the device performing the routing has changed.
