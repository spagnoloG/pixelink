#!/bin/sh

set -eux

echo "laboratorijzaintegracijo" | xargs sudo passwd


# Poor man login
set interfaces ethernet eth0 address '88.200.24.236/24'
set protocols static route 0.0.0.0/0 next-hop 88.200.24.1
set service ssh port 22
set system login user vyos authentication plaintext-password 'laboratorijzaintegracijo'


cat <<EOF 
configure
# Public interface
set interfaces ethernet eth0 address '88.200.24.236/24'
set interfaces ethernet eth0 address '2001:1470:fffd:94::2/64'
set interfaces ethernet eth0 description 'PUBLIC'
# Internal interface
set interfaces ethernet eth2 address '192.168.6.1/24'
set interfaces ethernet eth2 address '2001:1470:fffd:94:1::1/64'
set interfaces ethernet eth2 description 'INTERNAL'
# DMZ interface
set interfaces ethernet eth1 address '10.6.0.1/24'
set interfaces ethernet eth1 address '2001:1470:fffd:94:2::1/64'
set interfaces ethernet eth1 description 'DMZ'
# IPV6only interface
set interfaces ethernet eth3 address '2001:1470:fffd:94:3::1/64'
set interfaces ethernet eth3 description 'IPV6only'
# Gateway
set protocols static route 0.0.0.0/0 next-hop 88.200.24.1
set protocols static route6 ::/0 next-hop 2001:1470:fffd:94::
# SSH
set service ssh port 22
# Dhcp
set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 default-router 192.168.6.1
set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 dns-server 192.168.6.1
set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 range 0 start 192.168.6.100
set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 range 0 stop 192.168.6.200

set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 default-router 10.6.0.1
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 dns-server 10.6.0.1
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 range 0 start 10.6.0.100
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 range 0 stop 10.6.0.200

set service dhcpv6-server shared-network-name IPV6only subnet 2001:1470:fffd:94:3::/64 address-range start 2001:1470:fffd:94:3::100 stop 2001:1470:fffd:94:3::200
set service dhcpv6-server shared-network-name IPV6only subnet 2001:1470:fffd:94:3::/64 name-server 2001:1470:fffd:94:3::1

# Nat
set nat source rule 100 outbound-interface 'eth0'
set nat source rule 100 source address '192.168.6.0/24'
set nat source rule 100 translation address 'masquerade'

set nat source rule 110 outbound-interface 'eth0'
set nat source rule 110 source address '10.6.0.0/24'
set nat source rule 110 translation address 'masquerade'

commit
save
exit
EOF | bash

