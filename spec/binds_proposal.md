# Example

```yaml
---
specversion: "0.0.2"

id: etherpad-app
metadata:
  name: etherpad-app
  appversion: 0.0.1
  description: Atomic app for deploying basic etherpad
  location: docker.io/projectatomic/etherpad-centos7-atomicapp

params:
    - name: provider
      description: The specified default provider.
      default: kubernetes
graph:
  - name: mariadb-centos7-atomicapp
    source: docker://projectatomic/mariadb-centos7-atomicapp
  - name: etherpad-app
    params:
      - name: image
        description: The container image for etherpad
        default: centos/etherpad
      - name: hostport
        description: The host TCP port as the external endpoint
        default: 9001
      - name: db_user
        description: Database User
############################################################
# Addition to ParamsObject; See [1]
        binds:
          - mariadb-centos7-atomicapp::db_user
############################################################
      - name: db_pass
        description: Database Password
        binds:
          - mariadb-centos7-atomicapp::db_pass
      - name: db_name
        description: Database Name
        binds:
          - mariadb-centos7-atomicapp::db_name
      - name: db_host
        description: Database service hostname/ip
        default: mariadb
      - name: db_port
        description: Database service port
        default: 3306
    artifacts:
      docker:
        - file://artifacts/docker/etherpad-centos7-atomicapp-run
      kubernetes:
        - file://artifacts/kubernetes/etherpad-rc.yaml
        - file://artifacts/kubernetes/etherpad-svc.yaml
      openshift:
        - file://artifacts/openshift/etherpad-rc.yaml
        - file://artifacts/openshift/etherpad-svc.yaml
      marathon:
        - file://artifacts/marathon/etherpad.json
```

# Description

Adds `binds` sequence to a `ParamsObject` to introduce the idea of binding
two graph parameters together. Allows information to be entered once.

Simple example:

```yaml
graph:
  - name: mariadb-centos7-atomicapp
    source: docker://projectatomic/mariadb-centos7-atomicapp
  - name: etherpad-app # Source node
    params:
      - name: db_name # Source param name
        description: Database Name
        binds:
          - mariadb-centos7-atomicapp::db_name
          # ^ Dest node                ^ Dest param name
```

`etherpad-app::db_name -> mariadb-centos7-atomicapp::db_name`

JSON Representation...

```json
{
  "bindings": [
    {
      "src": "etherpad-app",
      "src_key": "db_name",
      "dest": "mariadb-centos7-atomicapp",
      "dest_key": "db_name"
    }
  ]
}
```

[Sample full cap-server response for nulecule detail request](https://github.com/fusor/cap-ui/blob/erik-wip/mocks/nulecule_detail.json)

# Questions

## Directional binding?

* Two way binding? (We discussed this, thinking one way is sufficient)

* What if I want to set a value in the etherpad-app to **pull** a value
from another nulecule in the graph, rather than **pushing** to.

```yaml
# pushes db_pass -> mariadb-centos7-atomicapp::db_pass
- name: db_pass
  description: Database Password
  bind_to:
    - mariadb-centos7-atomicapp::db_pass

# pulls db_pass <- mariadb-centos7-atomicapp::db_pass
- name: db_user
  description: Database Password
  bind_from:
    - mariadb-centos7-atomicapp::db_user
```

## Deeply Nested Nodes?

* What if I want to bind to another nulecule that may be more than one node
away?

`mariadb-centos7-atomicapp::node-2-away::db_user`

# Links

* [Nulecule Spec](https://github.com/projectatomic/nulecule/tree/master/spec)
* `[1]` [ParamsObject Spec](https://github.com/projectatomic/nulecule/tree/master/spec#parameters-object)
