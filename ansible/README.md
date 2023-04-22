# RK playbooks 

## Dependencies:
System:
```bash
# apt install python3 python3-pip python3-venv
```

Python:
```bash
python3 -m venv .venv
source ./.venv/bin/activate
pip install -r requirements.txt
```

Ansible (not needed for now):
```bash
ansible-galaxy install -r requirements.yml
```

### Setup DMZ nameserver
```bash
make dmz_nameserver
```

