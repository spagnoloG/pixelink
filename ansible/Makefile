.PHONY: all dmz_nameserver dmz_httpserver
SHELL := /bin/bash

all: dmz_nameserver dmz_httpserver dmz_ipaserver

dmz_nameserver:
	@ansible-playbook -i inventory playbooks/00-setup-dns-server.yml --limit dmz_nameserver
	@ansible-playbook -i inventory playbooks/20-setup-ntp.yml --limit dmz_nameserver

dmz_httpserver:
	@ansible-playbook -i inventory playbooks/40-setup-ldap-client.yml --limit dmz_httpserver

dmz_ipaserver:
	@ansible-playbook -i inventory playbooks/30-setup-freeipa-ldap-server.yml --limit dmz_ipaserver
	@ansible-playbook -i inventory playbooks/31-setup-ldap-users.yml --limit dmz_ipaserver

