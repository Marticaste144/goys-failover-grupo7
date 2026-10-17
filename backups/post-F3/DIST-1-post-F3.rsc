# 2026-10-17 01:39:44 by RouterOS 7.21.5
# system id = 8CvaGzltNFP
#
/interface bridge
add name=loopback
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/interface vrrp
add authentication=simple interface=ether3 name=vrrp10 priority=150 version=2 vrid=10
add authentication=simple interface=ether4 name=vrrp20 version=2 vrid=20
/routing ospf instance
add name=ospf-1 router-id=6.6.6.6
/routing ospf area
add instance=ospf-1 name=backbone
/ip address
add address=10.0.0.22/30 interface=ether1 network=10.0.0.20
add address=10.0.0.26/30 interface=ether2 network=10.0.0.24
add address=192.168.10.2/24 interface=ether3 network=192.168.10.0
add address=192.168.20.2/24 interface=ether4 network=192.168.20.0
add address=6.6.6.6 interface=loopback network=6.6.6.6
add address=192.168.10.1 interface=vrrp10 network=192.168.10.1
add address=192.168.20.1 interface=vrrp20 network=192.168.20.1
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/routing ospf interface-template
add area=backbone auth=md5 auth-id=1 interfaces=ether1,ether2 type=ptp
add area=backbone interfaces=loopback,ether3,ether4 passive
/system identity
set name=DIST-1
