
# 2026-10-08 19:07:14 by RouterOS 7.21.5
# system id = VUH42Gv5a2J
#
/interface bridge
add name=loopback
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
/ip address
add address=10.0.0.1/30 interface=ether1 network=10.0.0.0
add address=1.1.1.1 interface=loopback network=1.1.1.1
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
