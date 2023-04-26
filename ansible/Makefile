.PHONY: all dmz_nameserver dmz_httpserver
SHELL := /bin/bash

all: dmz_nameserver dmz_httpserver dmz_ipaserver internal_ubuntu_desktop_1

dmz_nameserver:
	@ansible-playbook -i inventory playbooks/00-setup-dns-server.yml --limit dmz_nameserver
	@ansible-playbook -i inventory playbooks/20-setup-ntp.yml --limit dmz_nameserver

dmz_httpserver:
	@ansible-playbook -i inventory playbooks/01-setup-dns-client.yml --limit dmz_httpserver
	@ansible-playbook -i inventory playbooks/40-setup-ldap-client.yml --limit dmz_httpserver

dmz_ipaserver:
	@ansible-playbook -i inventory playbooks/30-setup-freeipa-ldap-server.yml --limit dmz_ipaserver
	@ansible-playbook -i inventory playbooks/31-setup-ldap-users.yml --limit dmz_ipaserver

internal_ubuntu_desktop_1:
	@ansible-playbook -i inventory playbooks/01-setup-dns-client.yml --limit internal_ubuntu_desktop_1
	@ansible-playbook -i inventory playbooks/40-setup-ldap-client.yml --limit internal_ubuntu_desktop_1

