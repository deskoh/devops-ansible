Role Name
=========

Setup Artifactory with NGINX as reverse proxy.

Requirements
------------

Docker is required.

**Optional:** For convenience, the following DNS entries is required for docker domain name alias (see Repository layout for more infomation).

* cr.io

* p.cr.io

* m.cr.io

Role Variables
--------------

N.A.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

Post-Configuration
------------------

### Repository Layout

#### NPM

`npm-mirror`: Mirror for packages on `registry.npmjs.org`. This repo has restricted access control for deployment.

`npm-private`: Private / Project NPM packages.

`npm-public`: Staging repo for `npm-mirror` public contribution.

`npm`: Virtual repo for `npm-mirror`, `npm-private` and `npm-public` (Default publish repo).

#### Docker

For convenience, NGINX configuration also creates shorterned URL alias `cr.io` for the following Docker repositories.

`docker-mirror` (`m.cr.io`): Mirror for images on `Docker Hub`. This repo has restricted access control for deployment.

`docker-private` (`p.cr.io`): Private / Project images.

`docker-public`: Staging repo for `docker-mirror` public contribution.

`docker` (`cr.io`): Virtual repo for `docker-mirror`, `docker-private` and `docker-public`.

### Access Control Design

All LDAP users should have `Developer` permission as described below.

**Groups**: A `LDAP Users` group is created with *Automatically Join New Users to this Group* enabled.

**Permissions**: A `Developer` permission is created and applied to `LDAP Users` group to allow all repositories actions except `manage` for the following repositories:

* `docker-private`

* `docker-public`

* `npm-private`

* `npm-public`
