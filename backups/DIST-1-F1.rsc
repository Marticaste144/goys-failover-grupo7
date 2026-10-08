# 2026-10-08 18:38:48 by RouterOS 7.21.5
# system id = ajBhQ5rceuB
#
/interface bridge
add name=loopback
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/ip address
add address=10.0.0.22/30 interface=ether1 network=10.0.0.20
add address=10.0.0.26/30 interface=ether2 network=10.0.0.24
add address=192.168.10.2/24 interface=ether3 network=192.168.10.0
add address=192.168.20.2/24 interface=ether4 network=192.168.20.0
add address=6.6.6.6 interface=loopback network=6.6.6.6
/ip dhcp-client
add interface=ether1
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
