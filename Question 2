# Question 2 – Namespaces on Different Servers

If the namespaces are distributed across two different servers (virtual or physical) that share **Layer-2 connectivity** (Figure 3), a single router namespace can no longer connect both subnets. Instead, **each server acts as the router for its own local subnet**.

## Required configuration

### Server 1

- Configure the interface connected to **br1** with the gateway address `172.0.0.1/24`.
- Enable IPv4 forwarding.

### Server 2

- Configure the interface connected to **br2** with the gateway address `10.10.0.1/24`.
- Enable IPv4 forwarding.

## Static routing

Because each server only knows its directly connected network, static routes must be configured.

### On Server 1

Add a route indicating that the remote network:

- `10.10.0.0/24`

is reachable via **Server 2's IP address on the inter-server link**.

### On Server 2

Add a route indicating that:

- `172.0.0.0/24`

is reachable via **Server 1's IP address on the inter-server link**.

The servers route packets using the **next-hop IP address**. ARP then resolves that next-hop IP address to the appropriate MAC address across the shared Layer-2 network.

## Default routes inside namespaces

The namespaces continue to use their local server as the default gateway:

- Nodes in Server 1 → `172.0.0.1`
- Nodes in Server 2 → `10.10.0.1`

With IP forwarding enabled and the static routes configured, packets can be forwarded between the two subnets transparently.
