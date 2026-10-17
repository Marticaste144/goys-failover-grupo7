# 2026-10-17 02:24:42 by RouterOS 7.21.5
# system id = vdWfzG0BO8K
#
/interface bridge
add name=loopback
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/routing bgp instance
add as=65000 name=bgp-edge router-id=3.3.3.3
/routing ospf instance
add name=ospf-1 originate-default=if-installed router-id=3.3.3.3
/routing ospf area
add instance=ospf-1 name=backbone
/ip address
add address=10.0.0.2/30 interface=ether1 network=10.0.0.0
add address=10.0.0.6/30 interface=ether2 network=10.0.0.4
add address=10.0.0.9/30 interface=ether3 network=10.0.0.8
add address=10.0.0.13/30 interface=ether4 network=10.0.0.12
add address=3.3.3.3 interface=loopback network=3.3.3.3
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/routing bgp connection
add instance=bgp-edge local.address=10.0.0.2 .role=ebgp name=a-ISP1 output.filter-chain=ospf-a-bgp .redistribute=\
    ospf remote.address=10.0.0.1 .as=65001
add instance=bgp-edge local.address=10.0.0.6 .role=ebgp name=a-ISP2 output.filter-chain=ospf-a-bgp .redistribute=\
    ospf remote.address=10.0.0.5 .as=65002
/routing filter rule
add chain=ospf-a-bgp rule="if (dst == 192.168.10.0/24) { accept }"
add chain=ospf-a-bgp rule="if (dst == 192.168.20.0/24) { accept }"
add chain=ospf-a-bgp rule=reject
/routing ospf interface-template
add area=backbone auth=md5 auth-id=1 interfaces=ether3,ether4 type=ptp
add area=backbone interfaces=loopback passive
/system identity
set name=EDGE
