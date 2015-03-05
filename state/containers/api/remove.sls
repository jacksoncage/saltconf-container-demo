{% set name           = 'node-demo'   %}
{% set amount         = salt['pillar.get']('containers:api:amount:last', '') %}
{% set containerid    = salt['pillar.get']('containers:api:unactive', '') %}

# docker stop and remove
{% for no in range(0, amount|int + 1) %}
{{ name }}-stop-unactive-{{ no }}:
  docker.absent:
    - name: {{ containerid }}-{{ name }}-{{ no }}
{%- endfor %}
