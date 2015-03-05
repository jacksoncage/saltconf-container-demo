# Salt container deploy orchestration demo

Used for prestation at [SaltConf15](http://saltconf.com/). Discussed in more detail in blog post [Salt container deploy orchestration demo](http://jacksoncage.se)


# Architecture

*Servers*
  - **Dockyard** - Running salt master and api. Master controls etcd and docker registry mirror
  - **Ship's** - Running salt minion and docker.

## Config

There are some configuration regarding this demo which are not present, such as salt master/minion config. That configuration will be needed to deploy containers via salt api and reactor.


### Reactor

`/etc/salt/master.d/reactor.conf`

```
reactor:
  - 'salt/netapi/hook/api/deploy/phase1/*':
    - /srv/reactor/deploy-phase1.sls

  - 'salt/netapi/hook/api/deploy/phase2/*':
    - /srv/reactor/deploy-phase2.sls
```

###  External pillars

`/etc/salt/master`

```
etcd_config:
  etcd.host: etcd.lab.jacksoncage.se
  etcd.port: 4001

ext_pillar:
  - etcd: etcd_config root=/salt/shared
  - etcd: etcd_config root=/salt/private/%(minion_id)s
```

### Salt API

`/etc/salt/master`

```
rest_cherrypy:
  port: 8000
  host: 0.0.0.0
  debug: True
  disable_ssl: True
  webhook_disable_auth: True
  webhook_url: /hook
```
