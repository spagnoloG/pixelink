.PHONY: all dmz_nameserver dmz_httpserver
SHELL := /bin/bash

all: dmz_nameserver dmz_httpserver

dmz_nameserver:
	@ansible-playbook -i inventory playbooks/00-setup-dns-server.yml --limit dmz_nameserver
	@ansible-playbook -i inventory playbooks/20-setup-ntp.yml --limit dmz_nameserver

dmz_httpserver:
	@echo "TODO"
