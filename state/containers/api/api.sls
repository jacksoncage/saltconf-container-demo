{% set name           = 'node-demo'   %}
{% set registryname   = 'jacksoncage' %}
{% set tag            = salt['pillar.get']('containers:api:tag:new', '') %}
{% set amount         = salt['pillar.get']('containers:api:amount:new', '') %}
{% set containerid    = salt['pillar.get']('containers:api:unactive', '') %}
{% set hostip         = grains['ip_interfaces']['docker0'][0] %}

{% for no in range(0, amount|int + 1) %}
{{ name }}-container-{{ no }}:
  docker.installed:
    - name: {{ containerid }}-{{ name }}-{{ no }}
    - hostname: {{ containerid }}-{{ name }}-{{ no }}
    - image: {{ registryname }}/{{ name }}:{{ tag }}
    - ports:
        - "8080/tcp"
    - environment:
        - EXECUTER: "node"
        - APP: "index.js"
    - require_in: {{ name }}-{{ no }}

{{ name }}-{{ no }}:
  docker.running:
    - container: {{ containerid }}-{{ name }}-{{ no }}
    - port_bindings:
        "8080/tcp":
            HostIp: "{{ hostip }}"
            HostPort: ""
{%- endfor %}
