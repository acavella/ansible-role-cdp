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
# List of http(s) sources to retrieve CRLs from.
cdp_crl_sources: []

# List corresponding names to serve CRLs by.
cdp_crl_names: []

# A fqdn or IP used by the script to validate connectivity via ping.
cdp_source_fqdn: "ca1.example.com"

# The fqdn used by the CDP to server to serve files.
cdp_public_fqdn: "cdp.example.com"

# Directory to save and serve CRL files from.
cdp_www_dir: "/var/www/cdp"
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: localhost
  roles:
    - { role: ansible_role_cdp }
```
## License

GNU General Public License v3.0

## Author Information

This role was created in 2023 by [Tony Cavella](https://www.cavella.com/)
