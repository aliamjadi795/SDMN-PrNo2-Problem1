#!/bin/bash

# We first have to make sure script runs as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run the script as root via sudo command"
    exit 1
fi

echo "Creating Namespaces ..."
for ns in node1 node2; do
    ip netns add $ns
    ip netns exec $ns ip link set lo up
done

echo "Creating Bridges..."
ip link add name br type bridge
ip link set dev br up

echo "Connecting Nodes to The Bridge..."

# node1
# Create veth pair one end for the node, one for the bridge
ip link add veth-node1 type veth peer name veth-br1
ip link set veth-br1 master br
ip link set veth-br1 up

# Move node end to namespace and configure
ip link set veth-node1 netns node1
ip netns exec node1 ip addr add 172.0.0.2/24 dev veth-node1
ip netns exec node1 ip link set veth-node1 up

# node2
# doing the same above for node2
ip link add veth-node2 type veth peer name veth-br2
ip link set veth-br2 master br
ip link set veth-br2 up

#...
ip link set veth-node2 netns node2
ip netns exec node2 ip addr add 172.0.0.3/24 dev veth-node2
ip netns exec node2 ip link set veth-node2 up

echo "Topology setup complete!"
