# Ansible: Offline DevOps Environment (WIP)

Install the following on RHEL / CentOS servers.

* Jenkins Master and Slaves
* JFrog Artifactory / yum repo
* Grafana / Prometheus

## Variables

 Variables in `group_vars` and `host_vars` are listed below with default values.

### Group Variables: `all`

```yml
# Domain name of servers
domain_name: dev.local

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
```

### Group Variables: `jenkins_slaves`

```yml
# Raw disk to create partition, physical volume and data volume group on.
# Volume group will be named `data_vg_name`
pv_device: /dev/sdb

# Logical volumes to create for bind mount
lv_config:
  - { path: /var/lib/docker, size: 64g, name: var_lib_docker, become: yes }
  - { path: /var/jenkins_home, size: 60g, name: jenkins }
```

### Host Variables: `jenkins-master`

```yml
---
# Raw disk to create partition, physical volume and data volume group on.
# Volume group will be named `data_vg_name`
pv_device: /dev/sdb

# Logical volumes to create for bind mount
lv_config:
  - { path: /var/lib/docker, size: 128g, name: var_lib_docker, become: yes }
  - { path: /var/jenkins_home, size: 120g, name: jenkins }

```

### Host Variables: `repo`

```yml
# Raw disk to create partition, physical volume and data volume group on.
# Volume group will be named `data_vg_name`
pv_device: null

# Logical volumes to create for bind mount
lv_config:
  - { path: /var/lib/docker, size: 10g, name: var_lib_docker, become: yes }

# The data directory to create docker volume mounts
repo_data_dir: /data1

```

## Cheatsheet

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
```
