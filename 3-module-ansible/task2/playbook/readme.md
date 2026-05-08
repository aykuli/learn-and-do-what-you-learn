# Clickhouse with Vector Ansible-Playbook

## Prerequities:
| Machine | Prerequisite |
| --- | --- |
| Host | Ansible 2.9+ |
| Virtual Machine | Debian OS |

## Clickhouse and Vector Versions

This ansible-playbook maintains versions:

| Package name | version|
| --- | --- |
| clickhouse | 22.3.3.44 |
| vector | 0.55.0 |

Versions might be changed in [host_vars/clickhouse/vars.yml](./host_vars/clickhouse/vars.yml)

Playbook plays:
* Install Clickhouse
    * Downloads packages
    * Installs from downloaded required packages fro `clickhouse` - `client`, `server` and `clickhouse-common-static`
    * Starts clickhouse service
    * Creates logs database
* Install Vector
    * Downloads packages
    * Installs Vector
    * Creates configuration file from template and puts in place it should be
    * Notifies restart vector handler

