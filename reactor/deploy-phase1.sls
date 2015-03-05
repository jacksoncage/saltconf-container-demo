# This script is to be called from the reactor system
#
# 1. Sync states
# 2. Deploy new containers to cluster
#
# Example start deploy via curl:
#curl -H 'X-Salt-Deploy-Key: QmpaDa8T3UdFVBUHWo@T' \
#  -H 'Content-Type: application/json' \
#  -d '{"application":"api","container":"api-phase1","node":"ship01","tag":"1.0","amount":"2"}' \
#  http://127.0.0.1:8000/hook/api/deploy/phase2/success
#
{% set secret_key = data.get('headers', {}).get('X-Salt-Deploy-Key') %}
{% set deploy = data.get('post', {}) %}
{% if secret_key == 'QmpaDa8T3UdFVBUHWo@T' %}
# 1. Sync states
sync-states:
  cmd.saltutil.sync_states:
    - tgt: {{ deploy.node }}

# 2. Deploy new containers to cluster
deploy:
  cmd.state.sls:
    - tgt: {{ deploy.node }}
    - arg:
      - containers.api.{{ deploy.container }}
    - kwarg:
        pillar:
          containers:
            imagetag: {{ deploy.tag }}
            amount: {{ deploy.amount }}

{% endif %}
