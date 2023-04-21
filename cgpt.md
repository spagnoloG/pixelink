Open sidebar
VyOS Configuration Steps.

Model: GPT-4

Gašper Spagnolo
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
I want all my ipv6 nampaces to be on /64 subnet

Here's a step-by-step guide to configure a VyOS router for your network requirements.

Configure the interfaces:
arduino
Copy code
configure

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
vbnet
Copy code
set protocols static route 0.0.0.0/0 next-hop 88.200.24.1
set protocols static route6 ::/0 next-hop 2001:1470:fffd:94::1
Configure DHCP for IPv4:
vbnet
Copy code
set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 default-router 192.168.6.1
set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 dns-server 192.168.6.1
set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 range 0 start 192.168.6.100
set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 range 0 stop 192.168.6.200

set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 default-router 10.6.0.1
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 dns-server 10.6.0.1
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 range 0 start 10.6.0.100
set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 range 0 stop 10.6.0.200
Configure DHCPv6 for IPv6:
ruby
Copy code
set service dhcpv6-server shared-network-name INTERNAL subnet 2001:1470:fffd:94:1::/64 address-range start 2001:1470:fffd:94:1::100 stop 2001:1470:fffd:94:1::200
set service dhcpv6-server shared-network-name INTERNAL subnet 2001:1470:fffd:94:1::/64 name-server 2001:1470:fffd:94:1::1

set service dhcpv6-server shared-network-name DMZ subnet 2001:1470:fffd:94:2::/64 address-range start 2001:1470:fffd:94:2::100 stop 2001:1470:fffd:94:2::200
set service dhcpv6-server shared-network-name DMZ subnet 2001:1470:fffd:94:2::/64 name-server 2001:1470:fffd:94:2::1

set



Gašper Spagnolo
You did not finish..

Apologies for the incomplete response. Here is the continuation of the configuration.

Configure DHCPv6 for IPv6 (continued):
ruby
Copy code
set service dhcpv6-server shared-network-name IPV6only subnet 2001:1470:fffd:94:3::/64 address-range start 2001:1470:fffd:94:3::100 stop 2001:1470:fffd:94:3::200
set service dhcpv6-server shared-network-name IPV6only subnet 2001:1470:fffd:94:3::/64 name-server 2001:1470:fffd:94:3::1
Configure NAT for IPv4:
bash
Copy code
set nat source rule 100 outbound-interface 'eth0'
set nat source rule 100 source address '192.168.6.0/24'
set nat source rule 100 translation address 'masquerade'

set nat source rule 110 outbound-interface 'eth0'
set nat source rule 110 source address '10.6.0.0/24'
set nat source rule 110 translation address 'masquerade'
Configure firewall rules (optional):
You may want to configure firewall rules to allow or deny specific traffic between your networks. Here's a basic example to allow traffic from INTERNAL to DMZ and IPV6only networks:

sql
Copy code
set firewall name INTERNAL_TO_DMZ default-action drop
set firewall name INTERNAL_TO_DMZ rule 10 action accept
set firewall name INTERNAL_TO_DMZ rule 10 state established enable
set firewall name INTERNAL_TO_DMZ rule 10 state related enable
set firewall name INTERNAL_TO_DMZ rule 20 action accept
set firewall name INTERNAL_TO_DMZ rule 20 protocol all
set firewall name INTERNAL_TO_DMZ rule 20 source address 192.168.6.0/24
set firewall name INTERNAL_TO_DMZ rule 20 destination address 10.6.0.0/24

set interfaces ethernet eth2 firewall out name INTERNAL_TO_DMZ

set firewall ipv6-name INTERNAL_TO_IPV6only default-action drop
set firewall ipv6-name INTERNAL_TO_IPV6only rule 10 action accept
set firewall ipv6-name INTERNAL_TO_IPV6only rule 10 state established enable
set firewall ipv6-name INTERNAL_TO_IPV6only rule 10 state related enable
set firewall ipv6-name INTERNAL_TO_IPV6only rule 20 action accept
set firewall ipv6-name INTERNAL_TO_IPV6only rule 20 protocol all
set firewall ipv6-name INTERNAL_TO_IPV6only rule 20 source address 2001:1470:fffd:94:1::/64
set firewall ipv6-name INTERNAL_TO_IPV6only rule 20 destination address 2001:1470:fffd:94:3::/64

set interfaces ethernet eth2 firewall ipv6-out name INTERNAL_TO_IPV6only
Save and apply the configuration:
bash
Copy code
commit
save
exit
This configuration sets up the interfaces, routing, DHCP for IPv4 and IPv6, NAT for IPv4, and some basic firewall rules. You can further customize the configuration based on your specific network requirements.




Gašper Spagnolo
But are we missing a nat?

You are right. Since you have an IPv6 network, you'll need to set up NAT66 (NPTv6) for IPv6 if you want to provide network prefix translation for your IPv6 networks. Here's how you can do that:

Configure NAT66 (NPTv6):
bash
Copy code
set nat nptv6 rule 10 outbound-interface 'eth0'
set nat nptv6 rule 10 source prefix '2001:1470:fffd:94:1::/64'
set nat nptv6 rule 10 translation prefix '2001:1470:fffd:94:10::/64'

set nat nptv6 rule 20 outbound-interface 'eth0'
set nat nptv6 rule 20 source prefix '2001:1470:fffd:94:2::/64'
set nat nptv6 rule 20 translation prefix '2001:1470:fffd:94:20::/64'

set nat nptv6 rule 30 outbound-interface 'eth0'
set nat nptv6 rule 30 source prefix '2001:1470:fffd:94:3::/64'
set nat nptv6 rule 30 translation prefix '2001:1470:fffd:94:30::/64'
Save and apply the configuration:
bash
Copy code
commit
save
exit
This configuration sets up NAT66 (NPTv6) for your IPv6 networks in addition to the previous NAT configuration for IPv4. Please note that NAT66 (NPTv6) is not always necessary for IPv6 networks, as the address space is large




Gašper Spagnolo
What about ipv4 nat?

My earlier response already included the configuration for IPv4 NAT. Here's the configuration again for your reference:

Configure Source NAT for IPv4:
bash
Copy code
set nat source rule 100 outbound-interface 'eth0'
set nat source rule 100 source address '192.168.6.0/24'
set nat source rule 100 translation address 'masquerade'

set nat source rule 110 outbound-interface 'eth0'
set nat source rule 110 source address '10.6.0.0/24'
set nat source rule 110 translation address 'masquerade'
These two rules are for source NAT for your INTERNAL and DMZ IPv4 networks. The 'masquerade' keyword translates the source IP address to the IP address of the outgoing interface (eth0).

To apply the IPv4 NAT configuration, enter the VyOS configuration mode, input the above commands, and then commit, save, and exit:

bash
Copy code
configure
<enter the commands for NAT>
commit
save
exit
This configuration sets up source NAT for your IPv4 networks, translating the INTERNAL and DMZ IPv4 addresses to the public IP address when accessing the internet.




Send a message...


ChatGPT Mar 23 Version. ChatGPT may produce inaccurate information about people, places, or facts
New chat




#### TO SVA PA MI2 nrdila

set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 default-router 192.168.6.1

set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 dns-server 192.168.6.1

set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 range 0 start 192.168.6.100

set service dhcp-server shared-network-name INTERNAL subnet 192.168.6.0/24 range 0 stop 192.168.6.200

set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 default-router 10.6.0.1

set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 dns-server 10.6.0.1

set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 range 0 start 10.6.0.100

set service dhcp-server shared-network-name DMZ subnet 10.6.0.0/24 range 0 stop 10.6.0.200




vyos@vyos:~$ configure
[edit]
vyos@vyos# set nat source rule 100 outbound-interface 'eth0'
[edit]
vyos@vyos# set nat source rule 100 source address '192.168.6.0/24'
[edit]
vyos@vyos# set nat source rule 100 translation address 'masquerade'
[edit]
vyos@vyos#
[edit]
vyos@vyos# set nat source rule 110 outbound-interface 'eth0'
[edit]
vyos@vyos# set nat source rule 110 source address '10.6.0.0/24'
[edit]
vyos@vyos# set nat source rule 110 translation address 'masquerade'
[edit]
vyos@vyos# commit
[edit]
vyos@vyos# save
Saving configuration to '/config/config.boot'...
Done
[edit]
vyos@vyos# exit
exit

