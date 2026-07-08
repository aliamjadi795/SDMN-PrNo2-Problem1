#!/bin/bash

# We first have to make sure script runs as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run the script as root via sudo command"
    exit 1
fi

echo "Creating Namespaces ..."
for ns in node1 node2 node3 node4 router; do
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

#connecting router to br1 and br2
ip link add veth-r-br1 type veth peer name veth-r-br1-br
ip link set veth-r-br1-br master br1
ip link set veth-r-br1-br up
ip link set veth-r-br1 netns router
ip netns exec router ip addr add 172.0.0.1/24 dev veth-r-br1
ip netns exec router ip link set veth-r-br1 up

ip link add veth-r-br2 type veth peer name veth-r-br2-br
ip link set veth-r-br2-br master br2
ip link set veth-r-br2-br up
ip link set veth-r-br2 netns router
ip netns exec router ip addr add 10.10.0.1/24 dev veth-r-br2
ip netns exec router ip link set veth-r-br2 up

# this command will enable the router with ip forwarding
ip netns exec router sysctl -w net.ipv4.ip_forward=1

#here we add a defaul routing path to the nodes
ip netns exec node1 ip route add default via 172.0.0.1
ip netns exec node2 ip route add default via 172.0.0.1
ip netns exec node3 ip route add default via 10.10.0.1
ip netns exec node4 ip route add default via 10.10.0.1
echo "Topology setup complete!"