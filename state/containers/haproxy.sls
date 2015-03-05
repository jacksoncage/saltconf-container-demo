# Docker run command
# docker run -d --name my-running-haproxy -v /path/to/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro haproxy:latest
{% set name = 'haproxy' -%}
{% set hostip = grains['ip_interfaces']['eth0'][0] -%}

{{ name }}-dir:
  file.directory:
    - name: /data/docker/haproxy
    - user: root
    - group: users
    - mode: 755
    - makedirs: True

{{ name }}-cfg:
  file.managed:
    - name: /data/docker/haproxy/haproxy.cfg
    - source: salt://containers/files/haproxy.cfg
    - template: jinja
    - user: root
    - group: root
    - mode: 644

{{ name }}-image:
   docker.pulled:
     - name: haproxy
     - tag: latest
     - require_in: {{ name }}-container
     - force: True

{{ name }}-container:
  docker.installed:
    - name: {{ name }}
    - hostname: {{ name }}
    - image: haproxy:latest
    - ports:
        - "80/tcp"
    - volumes:
        - /data/docker/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg
    - require_in: {{ name }}

{{ name }}:
  docker.running:
    - container: {{ name }}
    - port_bindings:
        "80/tcp":
            HostIp: "{{ hostip }}"
            HostPort: "80"
    - binds:
        /data/docker/haproxy/haproxy.cfg:
          bind: /usr/local/etc/haproxy/haproxy.cfg
          ro: False

{{ name }}-reload:
  cmd.wait:
    - name: docker restart haproxy
    - user: root
    - group: root
    - watch:
      - file: haproxy-cfg
