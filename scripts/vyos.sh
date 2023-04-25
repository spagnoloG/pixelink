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
set protocols static route6 ::/0 next-hop 2001:1470:fffd:94::1
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

# DNS
set system name-server 8.8.8.8
set system name-server 8.8.4.4
set service dns forwarding name-server 8.8.8.8
set service dns forwarding name-server 8.8.4.4
set service dns forwarding allow-from 192.168.6.0/24
set service dns forwarding allow-from 10.6.0.0/24
set system ipv6 forwarding enable

# Firewall
# Define default firewall policies
set firewall name PUBLIC_IN default-action 'drop'
set firewall name PUBLIC_LOCAL default-action 'drop'
set firewall name INTERNAL_IN default-action 'accept'
set firewall name INTERNAL_LOCAL default-action 'accept'
set firewall name DMZ_IN default-action 'accept'
set firewall name DMZ_LOCAL default-action 'accept'

# Allow established and related traffic in the PUBLIC_IN firewall
set firewall name PUBLIC_IN rule 10 action 'accept'
set firewall name PUBLIC_IN rule 10 state established 'enable'
set firewall name PUBLIC_IN rule 10 state related 'enable'

# Allow ICMP (ping) in the PUBLIC_IN firewall
set firewall name PUBLIC_IN rule 20 action 'accept'
set firewall name PUBLIC_IN rule 20 icmp type-name 'echo-request'
set firewall name PUBLIC_IN rule 20 protocol 'icmp'

# Allow SSH access in the PUBLIC_IN firewall
set firewall name PUBLIC_IN rule 40 action 'accept'
set firewall name PUBLIC_IN rule 40 destination port '22'
set firewall name PUBLIC_IN rule 40 protocol 'tcp'

# Allow specific inbound services from public network to DMZ
# Example: Allow HTTP (TCP port 80) and HTTPS (TCP port 443)
set firewall name PUBLIC_IN rule 30 action 'accept'
set firewall name PUBLIC_IN rule 30 destination port '80,443'
set firewall name PUBLIC_IN rule 30 protocol 'tcp'

# Apply firewall policies to the interfaces
set interfaces ethernet eth0 firewall in name 'PUBLIC_IN'
set interfaces ethernet eth0 firewall local name 'PUBLIC_LOCAL'
set interfaces ethernet eth2 firewall in name 'INTERNAL_IN'
set interfaces ethernet eth2 firewall local name 'INTERNAL_LOCAL'
set interfaces ethernet eth1 firewall in name 'DMZ_IN'
set interfaces ethernet eth1 firewall local name 'DMZ_LOCAL'

# Static ip addresses
# DMZ
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 static-mapping DMZ_FREEIPA ip-address 10.6.0.105
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 static-mapping DMZ_FREEIPA mac-address '00:0c:29:5a:fd:a6'
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 static-mapping DMZ_NAMESERVER ip-address 10.6.0.100
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 static-mapping DMZ_NAMESERVER mac-address '00:0c:29:2e:eb:e6'
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 static-mapping DMZ_HTTPSERVER ip-address 10.6.0.102
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 static-mapping DMZ_HTTPSERVER mac-address '00:0c:29:88:1f:81'

# DNS
set system name-server 10.6.0.100
set service dns forwarding name-server 10.6.0.100
set service dns forwarding listen-address 10.6.0.1

commit
save
exit
EOF | bash

