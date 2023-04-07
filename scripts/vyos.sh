#!/bin/sh

set -eux

echo "laboratorijzaintegracijo" | xargs sudo passwd

cat <<EOF 
configure
set interface ethernet eth0 address 88.200.24.236 
set interface ethernet eth0 description "kp06_public_interface"
set protocols static route 0.0.0.0/0 next-hop 88.200.24.1
set service ssh port 22
commit
save
exit
EOF | bash

