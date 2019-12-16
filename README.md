# Ansible: Offline DevOps Environment (WIP)

[![Build Status](https://travis-ci.org/deskoh/devops-ansible.svg?branch=master)](https://travis-ci.org/deskoh/devops-ansible)

Install the following on CentOS servers.

* Jenkins Master and Slaves
* JFrog Artifactory / yum repo
* Grafana / Prometheus

> Variable secrets can be encrypted using `ansible-vault` by running `./encrypt.sh`. The vault password can be provided in `.vault_pass` as defined in `ansible.cfg`.

## Pre-Conditions

### Server List / Configuration

* Jenkins Master

  * Mimimum 250GB raw disk `/dev/sdb`

* Jenkins Slave

  * Mimimum 250GB raw disk `/dev/sdb`

* Repository (JFrog Artifactory / yum)

  * Volume group named `vg_data` (defined in `group_vars\all`) available.

  * Local yum repository (see `group_vars\all`)

* Grafana / Prometheus

  * Mimimum 50GB raw disk `/dev/sdb`

* LDAP Server for Single-Sign-On

### DNS Entries

* `jenkins`: Jenkins Master

* Jenkins Slave 1 ... N

* `grafana`: Grafana / Prometheus: 

* `*.repo` `docker`: JFrog Artifactory

## Variables

 Variables in `group_vars` and `host_vars` are listed below with default values.

### Group Variables: `all`

```yml
# Domain name of servers
domain_name: dev.pc8.dsta

# DNS servers
dns_servers: ['130.8.20.130']

# Inventory hostname of yum repo server.
# A local yum repo will be configured instead of a remote repo.
# See `hosts` file for inventory.
yum_inventory_hostname: repo

# Local yum repo path on repo host.
# Directory should contains centos-{base, updates, extras}.
# Path should not end with trailing slash.
local_yum_path=/data1/fileserver/yum

# The LVM volume group to create new logical volumes on.
data_vg_name: vg_data

# Insecure registries for docker daemon to use HTTP instead of HTTPS
insecure_registries:
  - docker.repo.{{ domain_name }}
  - docker.{{ domain_name }}

# Private docker registry url to pull image from
# URL should end with the trailing slash
docker_registry: docker.{{ domain_name }}/
```

### Group Variables: `jenkins_slaves`

```yml
# Raw disk to create partition, physical volume and data volume group on.
# Volume group will be named `data_vg_name`
pv_device: /dev/sdb

# Logical volumes to create for bind mount
lv_config:
  - { path: /var/lib/docker, size: 64g, name: var_lib_docker }
  - { path: /var/jenkins_home, size: 60g, name: jenkins, uid: 1000 }
```

### Host Variables: `jenkins-master`

```yml
---
# Raw disk to create partition, physical volume and data volume group on.
# Volume group will be named `data_vg_name`
pv_device: /dev/sdb

# Logical volumes to create for bind mount
lv_config:
  - { path: /var/lib/docker, size: 128g, name: var_lib_docker }
  - { path: /var/jenkins_home, size: 120g, name: jenkins, uid: 1000 }

```

### Host Variables: `repo`

```yml
# Raw disk to create partition, physical volume and data volume group on.
# Volume group will be named `data_vg_name`
pv_device: null

# Logical volumes to create for bind mount
lv_config:
  - { path: /var/lib/docker, size: 10g, name: var_lib_docker }

# The data directory to create docker volume mounts
docker_vol_mount_dir: /data1
```

### Host Variables: `grafana`

```yml
# The data directory to create docker volume mounts
docker_vol_mount_dir: /data

# Raw disk to create partition, physical volume and data volume group on.
# Volume group will be named `data_vg_name`
pv_device: /dev/sdb

# Logical volumes to create for bind mount
lv_config:
  - { path: /var/lib/docker, size: 20g, name: var_lib_docker }
  - { path: {{ docker_vol_mount_dir }}, size: 20g, name: lv_data }
```

## Default Login Credentials

* Jenkins: `cat /var/lib/jenkins_home/secrets/initialAdminPassword`
* Grafana: admin / admin

## SSH Keys setup

```sh
# Create RSA key pair on host
ssh-keygen -t rsa

# Copy public key to target
ssh-copy-id user@target

# Alternatively
cat ~/.ssh/id_rsa.pub | ssh user@target "mkdir -p ~/.ssh & chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Running playbook
ansible-playbook -K -i hosts site.yml
ansible-playbook -K -i hosts --limit jenkins site.yml
ansible-playbook -K -i hosts --limit jenkins-slave-1 site.yml

# Dry-run
ansible-playbook -K -i hosts site.yml --check
ansible-playbook -K -i hosts --limit jenkins site.yml --check
ansible-playbook -K -i hosts --limit jenkins-slave-1 site.yml --check

# Test
ansible-playbook -v -i hosts site.yml --syntax-check
ansible-playbook -v -i jenkins, site.yml --syntax-check

# Debug variables
ansible -i hosts -m debug -a 'var=hostvars[inventory_hostname]' jenkins
ansible -i hosts -m debug -a 'var=ldap_server' jenkins
```
