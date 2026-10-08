# 2026-10-08 18:38:41 by RouterOS 7.21.5
# system id = cJSlPmG23FH
#
/interface bridge
add name=loopback
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/ip address
add address=10.0.0.2/30 interface=ether1 network=10.0.0.0
add address=10.0.0.6/30 interface=ether2 network=10.0.0.4
add address=10.0.0.9/30 interface=ether3 network=10.0.0.8
add address=10.0.0.13/30 interface=ether4 network=10.0.0.12
add address=3.3.3.3 interface=loopback network=3.3.3.3
/ip dhcp-client
add interface=ether1
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
