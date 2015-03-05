{% set name           = 'node-demo'   %}
{% set registryname   = 'jacksoncage' %}
{% set tag            = salt['pillar.get']('containers:api:tag:new', '') %}
{% set amount         = salt['pillar.get']('containers:api:amount', '') %}
{% set containerid    = salt['pillar.get']('containers:api:unactive', '') %}
{% set hostip         = grains['ip_interfaces']['lo'][0] %}

{{ name }}-image:
  docker.pulled:
    - name: {{ registryname }}/{{ name }}
    - tag: {{ tag }}
    - force: True

{% for no in range(1, amount + 1) %}
{{ name }}-stop-if-old-{{ no }}:
  cmd.run:
    - name: docker stop {{ containerid }}-{{ name }}-{{ no }}
    - unless: docker inspect --format '{% raw %}{{ .Image }}{% endraw %}' {{ containerid }}-{{ name }}-{{ no }} | grep $(docker images --no-trunc | grep "{{ registryname }}/{{ name }}" | awk '{ print $3 }')
    - require:
      - docker: {{ name }}-image

{{ name }}-remove-if-old-{{ no }}:
  cmd.run:
    - name: docker rm {{ containerid }}-{{ name }}-{{ no }}
    - unless: docker inspect --format '{% raw %}{{ .Image }}{% endraw %}' {{ containerid }}-{{ name }}-{{ no }} | grep $(docker images --no-trunc | grep "{{ registryname }}/{{ name }}" | awk '{ print $3 }')
    - require:
      - cmd: {{ name }}-stop-if-old-{{ no }}

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
    - require:
      - docker: {{ name }}-image

{{ name }}-{{ no }}:
  docker.running:
    - container: {{ containerid }}-{{ name }}-{{ no }}
    - port_bindings:
        "8080/tcp":
            HostIp: "{{ hostip }}"
            HostPort: ""
{%- endfor %}
