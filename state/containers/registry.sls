{% set name = 'registry' %}
{% set hostip = grains['ip_interfaces']['eth0'][0] %}

{{ name }}-dir:
  file.directory:
    - name: /data/docker/mirror
    - user: root
    - group: users
    - mode: 755
    - makedirs: True

{{ name }}-image:
   docker.pulled:
     - name: h3nrik/simple-registry-mirror:latest
     - require_in: {{ name }}-container
     - force: True

{{ name }}-container:
  docker.installed:
    - name: {{ name }}-mirror
    - hostname: {{ name }}-mirror
    - image: h3nrik/simple-registry-mirror:latest
    - ports:
        - "5000/tcp"
    - volumes:
        - /data/docker/mirror:/opt/registry
    - require_in: {{ name }}

{{ name }}:
  docker.running:
    - container: {{ name }}-mirror
    - port_bindings:
        "5000/tcp":
            HostIp: "{{ hostip }}"
            HostPort: "5000"
    - binds:
        /data/docker/mirror/:
          bind: /opt/registry
          rw: True
