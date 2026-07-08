#!/bin/bash

# We first have to make sure script runs as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run the script as root via sudo command"
    exit 1
fi

echo "Creating Namespaces ..."
for ns in node1 node2 node3 node4; do
    ip netns add $ns
    ip netns exec $ns ip link set lo up
done

echo "Creating Bridges..."
ip link add br1 type bridge
ip link set br1 up

ip link add br2 type bridge
ip link set br2 up


echo "Connecting Nodes to The Bridge..."

connect_node() {
    NODE=$1
    BRIDGE=$2
    IP=$3
    VETH_NODE="veth-${NODE}"
    VETH_BR="veth-${NODE}-br"

    ip link add $VETH_NODE type veth peer name $VETH_BR
    ip link set $VETH_BR master $BRIDGE
    ip link set $VETH_BR up

    ip link set $VETH_NODE netns $NODE
    ip netns exec $NODE ip addr add $IP dev $VETH_NODE
    ip netns exec $NODE ip link set $VETH_NODE up
}
echo "Connecting nodes to bridges..."
connect_node node1 br1 172.0.0.2/24
connect_node node2 br1 172.0.0.3/24

connect_node node3 br2 10.10.0.2/24
connect_node node4 br2 10.10.0.3/24
echo "Topology setup complete!"