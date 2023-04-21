Open sidebar
VyOS Configuration Steps.


Hey generate me a vyos configuration steps for this type of network
## PUBLIC
- ipv4 = 88.200.24.236/24, ipv6 = 2001:1470:fffd:94::2/64
- **eth0** interface

## INTERNAL
- ipv4 = 192.168.6.0/24, ipv6 = 2001:1470:fffd:94::/62
- **eth2** interface

## DMZ
- ipv4 = 10.6.0.0/24, ipv6 = 2001:1470:fffd:94::/62
- **eth1** interface

## IPV6only
- ipv6 = 2001:1470:fffd:94::/62
- **eth3** interface

Here's a step-by-step guide to configure a VyOS router for your network requirements.


set interfaces ethernet eth0 address '88.200.24.236/24'
set interfaces ethernet eth0 address '2001:1470:fffd:94::2/64'
set interfaces ethernet eth0 description 'PUBLIC'

set interfaces ethernet eth2 address '192.168.6.1/24'
set interfaces ethernet eth2 address '2001:1470:fffd:94:1::1/64'
set interfaces ethernet eth2 description 'INTERNAL'

set interfaces ethernet eth1 address '10.6.0.1/24'
set interfaces ethernet eth1 address '2001:1470:fffd:94:2::1/64'
set interfaces ethernet eth1 description 'DMZ'

set interfaces ethernet eth3 address '2001:1470:fffd:94:3::1/64'
set interfaces ethernet eth3 description 'IPV6only'

Configure the routing:
set protocols static route 0.0.0.0/0 next-hop 88.200.24.1
set protocols static route6 2001:1470:fffd:94::/64 next-hop 2001:1470:fffd:94::1

Configure DHCP for IPv4:

set interfaces ethernet eth0 ipv6 router-advert prefix 2001:1470:fffd:94::/64


set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 default-router 192.168.6.1
set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 dns-server 192.168.6.1
set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 range 0 start 192.168.6.100
set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 range 0 stop 192.168.6.200

set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 default-router 10.6.0.1
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 dns-server 10.6.0.1
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 range 0 start 10.6.0.100
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 range 0 stop 10.6.0.200

set service dhcpv6-server shared-network-name INTERNAL subnet 2001:1470:fffd:94:1::/64 address-range start 2001:1470:fffd:94:1::100 stop 2001:1470:fffd:94:1::200
set service dhcpv6-server shared-network-name INTERNAL subnet 2001:1470:fffd:94:1::/64 name-server 2001:1470:fffd:94:1::1

set service dhcpv6-server shared-network-name DMZ subnet 2001:1470:fffd:94:2::/64 address-range start 2001:1470:fffd:94:2::100 stop 2001:1470:fffd:94:2::200
set service dhcpv6-server shared-network-name DMZ subnet 2001:1470:fffd:94:2::/64 name-server 2001:1470:fffd:94:2::1

set service dhcpv6-server shared-network-name IPV6only subnet 2001:1470:fffd:94:3::/64 address-range start 2001:1470:fffd:94:3::100 stop 2001:1470:fffd:94:3::200
set service dhcpv6-server shared-network-name IPV6only subnet 2001:1470:fffd:94:3::/64 name-server 2001:1470:fffd:94:3::1

set nat source rule 100 outbound-interface 'eth0'
set nat source rule 100 source address '192.168.6.0/24'
set nat source rule 100 translation address 'masquerade'

set nat source rule 110 outbound-interface 'eth0'
set nat source rule 110 source address '10.6.0.0/24'
set nat source rule 110 translation address 'masquerade'

set nat nptv6 rule 10 outbound-interface 'eth0'
set nat nptv6 rule 10 source prefix '2001:1470:fffd:94:1::/64'
set nat nptv6 rule 10 translation prefix '2001:1470:fffd:94:10::/64'

set nat nptv6 rule 20 outbound-interface 'eth0'
set nat nptv6 rule 20 source prefix '2001:1470:fffd:94:2::/64'
set nat nptv6 rule 20 translation prefix '2001:1470:fffd:94:20::/64'

set nat nptv6 rule 30 outbound-interface 'eth0'
set nat nptv6 rule 30 source prefix '2001:1470:fffd:94:3::/64'
set nat nptv6 rule 30 translation prefix '2001:1470:fffd:94:30::/64'
