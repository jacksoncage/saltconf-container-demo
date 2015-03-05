{% set name           = 'node-demo'   %}
{% set registryname   = 'jacksoncage' %}
{% set tag            = salt['pillar.get']('containers:api:tag:new', '') %}

{{ name }}-image:
  docker.pulled:
    - name: {{ registryname }}/{{ name }}
    - tag: {{ tag }}
    - force: True
