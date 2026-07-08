#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root via sudo command"
  exit
fi

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_node> <destination_node>"
    exit 1
fi

SRC=$1
DST=$2

# manually setting destination IP address
case $DST in
    node1) DST_IP="172.0.0.2" ;;
    node2) DST_IP="172.0.0.3" ;;
    node3) DST_IP="10.10.0.2" ;;
    node4) DST_IP="10.10.0.3" ;;
    *) 
        echo "Unknown destination node: $DST"
        exit 1 
        ;;
esac

echo "Pinging $DST ($DST_IP) from $SRC..."
ip netns exec $SRC ping $DST_IP

