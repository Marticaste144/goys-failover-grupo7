# 2026-10-20 16:22:07 by RouterOS 7.21.5
# system id = vdWfzG0BO8K
#
/interface bridge
add name=loopback
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/interface list
add name=WAN
add name=INTERNAS
/routing bgp instance
add as=65000 name=bgp-edge router-id=3.3.3.3
/routing ospf instance
add name=ospf-1 originate-default=if-installed router-id=3.3.3.3
/routing ospf area
add instance=ospf-1 name=backbone
/snmp community
set [ find default=yes ] disabled=yes
add addresses=192.168.10.0/24 authentication-protocol=SHA1 encryption-protocol=AES name=\
    monitor-g7 security=private
/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=WAN
add interface=ether3 list=INTERNAS
add interface=ether4 list=INTERNAS
/ip address
add address=10.0.0.2/30 interface=ether1 network=10.0.0.0
add address=10.0.0.6/30 interface=ether2 network=10.0.0.4
add address=10.0.0.9/30 interface=ether3 network=10.0.0.8
add address=10.0.0.13/30 interface=ether4 network=10.0.0.12
add address=3.3.3.3 interface=loopback network=3.3.3.3
/ip firewall address-list
add address=192.168.10.0/24 list=GESTION
/ip firewall filter
add action=accept chain=input comment="F3 retorno" connection-state=established,related
add action=drop chain=input comment="F3 invalidos" connection-state=invalid
add action=accept chain=input comment="F3 ICMP" protocol=icmp
add action=accept chain=input comment="F3 BGP ISP-1" dst-port=179 protocol=tcp src-address=\
    10.0.0.1
add action=accept chain=input comment="F3 BGP ISP-2" dst-port=179 protocol=tcp src-address=\
    10.0.0.5
add action=accept chain=input comment="F3 OSPF interno" in-interface-list=INTERNAS protocol=\
    ospf
add action=accept chain=input comment="F3 gestion SSH/WinBox" dst-port=22,8291 protocol=tcp \
    src-address-list=GESTION
add action=accept chain=input comment="F4 SNMP desde gestion" dst-port=161 protocol=udp \
    src-address-list=GESTION
add action=drop chain=input comment="F3 todo lo demas al router"
add action=accept chain=forward comment="F3 retorno" connection-state=established,related
add action=drop chain=forward comment="F3 invalidos" connection-state=invalid
add action=drop chain=forward comment="F3 nada nuevo desde los ISP" connection-state=new \
    in-interface-list=WAN
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/routing bgp connection
add instance=bgp-edge local.address=10.0.0.2 .role=ebgp name=a-ISP1 output.filter-chain=\
    ospf-a-bgp .redistribute=ospf remote.address=10.0.0.1 .as=65001
add instance=bgp-edge local.address=10.0.0.6 .role=ebgp name=a-ISP2 output.filter-chain=\
    ospf-a-bgp .redistribute=ospf remote.address=10.0.0.5 .as=65002
/routing filter rule
add chain=ospf-a-bgp rule="if (dst == 192.168.10.0/24) { accept }"
add chain=ospf-a-bgp rule="if (dst == 192.168.20.0/24) { accept }"
add chain=ospf-a-bgp rule=reject
/routing ospf interface-template
add area=backbone auth=md5 auth-id=1 interfaces=ether3,ether4 type=ptp
add area=backbone interfaces=loopback passive
/snmp
set contact="Grupo 7" enabled=yes location="GNS3 EDGE"
/system identity
set name=EDGE
/tool netwatch
add comment="F4 ISP-1" down-script=":log error \"NETWATCH ISP-1 DOWN\"" host=10.0.0.1 \
    interval=5s timeout=1s type=simple up-script=":log warning \"NETWATCH ISP-1 UP\""
add comment="F4 ISP-2" down-script=":log error \"NETWATCH ISP-2 DOWN\"" host=10.0.0.5 \
    interval=5s timeout=1s type=simple up-script=":log warning \"NETWATCH ISP-2 UP\""
add comment="F4 CORE-1" down-script=":log error \"NETWATCH CORE-1 DOWN\"" host=10.0.0.10 \
    interval=5s timeout=1s type=simple up-script=":log warning \"NETWATCH CORE-1 UP\""
add comment="F4 CORE-2" down-script=":log error \"NETWATCH CORE-2 DOWN\"" host=10.0.0.14 \
    interval=5s timeout=1s type=simple up-script=":log warning \"NETWATCH CORE-2 UP\""
