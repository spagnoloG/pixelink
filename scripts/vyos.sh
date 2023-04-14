#!/bin/sh

set -eux

echo "laboratorijzaintegracijo" | xargs sudo passwd

cat <<EOF 
configure
set interface ethernet eth0 address 88.200.24.236/24
set interfaces ethernet eth0 address '2001:1470:fffd:94::2/64'
set interface ethernet eth0 description "kp06_public_interface"
set protocols static route 0.0.0.0/0 next-hop 88.200.24.1
set protocols static route6 ::/0 next-hop 2001:1470:fffd:94::
set service ssh port 22
commit
save
exit
EOF | bash

