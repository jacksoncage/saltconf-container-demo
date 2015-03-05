# Phase2 reactor sls
#
# 1. Sync states
# 2. Update etcd tags
# 3. Pull docker image
# 4. deploy new containers to cluster
# 5. Add new containers to etcd
# 6. Update haproxy using etcd
# 7. Close down containers
#
# Example start deploy via curl:
#curl -H 'X-Salt-Deploy-Key: QmpaDa8T3UdFVBUHWo@T' \
#  -H 'Content-Type: application/json' \
#  -d '{"application":"api","container":"api","node":"ship01","tag":"1.0","amount":"2"}' \
#  http://127.0.0.1:8000/hook/api/deploy/phase2/success
#
{% set secret_key = data.get('headers', {}).get('X-Salt-Deploy-Key') %}
{% set deploy = data.get('post', {}) %}
{% if secret_key == 'QmpaDa8T3UdFVBUHWo@T' %}
# 1. Sync states
# salt ship01 saltutil.sync_states
sync-states:
  cmd.saltutil.sync_states:
    - tgt: {{ deploy.node }}

# 2. Update etcd tags
# salt ship01 state.sls containers.api.etcd.add 'pillar={ containers: { imagetag: latest, image: node-demo, name: api, container: api, amount: 2 } }'
etcd-add:
  cmd.state.sls:
    - tgt: {{ deploy.node }}
    - arg:
      - containers.api.etcd.add
    - kwarg:
        pillar:
          containers:
            imagetag: {{ deploy.tag }}
            image: {{ deploy.image }}
            name: {{ deploy.application }}
            container: {{ deploy.container }}
            amount: {{ deploy.amount }}

# 3. Pull docker image
# salt ship01 state.sls containers.api.pull
pull:
  cmd.state.sls:
    - tgt: {{ deploy.node }}
    - arg:
      - containers.api.pull

# 4. deploy new containers to cluster
# salt ship01 state.sls containers.api.api
deploy:
  cmd.state.sls:
    - tgt: {{ deploy.node }}
    - arg:
      - containers.api.{{ deploy.container }}
    - failhard: True

# 5. Add new containers to etcd
# salt ship01 state.sls containers.api.etcd.update
etcd-update:
  cmd.state.sls:
    - tgt: {{ deploy.node }}
    - arg:
      - containers.api.etcd.update
    - failhard: True

# 6. Update haproxy using etcd
# salt ship01 state.sls containers.haproxy
loadbalancer:
  cmd.state.sls:
    - tgt: {{ deploy.node }}
    - arg:
      - containers.haproxy

# 7. Close down containers
# salt ship01 state.sls containers.api.remove
remove:
  cmd.state.sls:
    - tgt: {{ deploy.node }}
    - arg:
      - containers.api.remove

{% endif %}
