# Ansible Role: CDP

![CI](https://github.com/acavella/ansible-role-cdp/actions/workflows/ci.yml/badge.svg)
![GitHub last commit](https://img.shields.io/github/last-commit/acavella/ansible-role-cdp)
![GitHub repo size](https://img.shields.io/github/repo-size/acavella/ansible-role-cdp)

An Ansible Role that installs and configures a simple CDP on Linux.

## Requirements

N/A

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
# Public ethernet adapter
public_ethernet_interface: eth0

# Port that must be accessible via public
wireguard_port: 51820
```

Private and public keys used to define initial server and client configurations.

```yaml
server_private_key_encoded:  set to generated wireguard server private key, base64 encoded.
client_public_key_encoded:   set to generated wireguard client public key, base64 encoded.
server_private_key_decoded:  base64 decoded version of above key, used in wg0.conf.j2
client_public_key_decoded:   base64 decoded version of above key, used in wg0.conf.j2
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: localhost
  roles:
    - { role: acavella.cdp }
```
## License

GNU General Public License v3.0

## Author Information

This role was created in 2023 by [Tony Cavella](https://www.cavella.com/)
