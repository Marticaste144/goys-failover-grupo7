# 2026-10-20 16:22:26 by RouterOS 7.21.5
# system id = SSypPG6/kSI
#
/interface bridge
add name=loopback
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
/routing bgp instance
add as=65001 name=bgp-isp1 router-id=1.1.1.1
/snmp community
set [ find default=yes ] disabled=yes
add addresses=192.168.10.0/24 authentication-protocol=SHA1 encryption-protocol=AES name=monitor-g7 security=\
    private
/ip address
add address=10.0.0.1/30 interface=ether1 network=10.0.0.0
add address=1.1.1.1 interface=loopback network=1.1.1.1
add address=8.8.8.8 comment="F4 destino Internet simulado" interface=loopback network=8.8.8.8
/ip firewall address-list
add address=1.1.1.1 list=anuncio-isp
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/routing bgp connection
add instance=bgp-isp1 local.address=10.0.0.1 .role=ebgp name=a-EDGE output.default-originate=always .network=\
    anuncio-isp remote.address=10.0.0.2 .as=65000
/snmp
set contact="Grupo 7" enabled=yes location="GNS3 ISP-1"
/system identity
set name=ISP-1
