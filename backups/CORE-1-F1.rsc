# 2026-10-08 19:07:06 by RouterOS 7.21.5
# system id = a8q5flSo21A
#
/interface bridge
add name=loopback
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/ip address
add address=10.0.0.10/30 interface=ether1 network=10.0.0.8
add address=10.0.0.17/30 interface=ether2 network=10.0.0.16
add address=10.0.0.21/30 interface=ether3 network=10.0.0.20
add address=10.0.0.29/30 interface=ether4 network=10.0.0.28
add address=4.4.4.4 interface=loopback network=4.4.4.4
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
