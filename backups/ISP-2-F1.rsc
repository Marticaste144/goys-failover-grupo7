
# 2026-10-08 18:36:30 by RouterOS 7.21.5
# system id = rKlXR3dEFCJ
#
/interface bridge
add name=loopback
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
/ip address
add address=10.0.0.5/30 interface=ether1 network=10.0.0.4
add address=2.2.2.2 interface=loopback network=2.2.2.2
/ip dhcp-client
add interface=ether1
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
