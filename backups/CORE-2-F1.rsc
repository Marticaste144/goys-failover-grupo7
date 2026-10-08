
# 2026-10-08 18:38:45 by RouterOS 7.21.5
# system id = ATuJiFna/jE
#
/interface bridge
add name=loopback
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/ip address
add address=10.0.0.14/30 interface=ether1 network=10.0.0.12
add address=10.0.0.18/30 interface=ether2 network=10.0.0.16
add address=10.0.0.25/30 interface=ether3 network=10.0.0.24
add address=10.0.0.33/30 interface=ether4 network=10.0.0.32
add address=5.5.5.5 interface=loopback network=5.5.5.5
/ip dhcp-client
add interface=ether1
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
