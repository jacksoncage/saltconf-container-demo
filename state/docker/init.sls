{% set url = salt['pillar.get']('containers:registry:url', 'http://127.0.0.1') %}

include:
  - python-pip

docker-default:
  file.managed:
    - name: /etc/default/docker
    - source: salt://docker/files/docker-default
    - template: jinja
    - context:
        URL: {{ url }}
    - require_in:
        - service: docker

docker-python-apt:
  pkg.installed:
    - name: python-apt

docker-dependencies:
   pkg.installed:
    - pkgs:
      - iptables
      - ca-certificates
      - lxc

docker_repo:
    pkgrepo.managed:
      - repo: 'deb http://get.docker.io/ubuntu docker main'
      - file: '/etc/apt/sources.list.d/docker.list'
      - key_url: salt://docker/files/docker.pgp
      - require_in:
          - pkg: lxc-docker
      - require:
        - pkg: docker-python-apt

lxc-docker:
  pkg.latest:
    - require:
      - pkg: docker-dependencies

docker:
  service.running:
    - name: docker
    - watch:
      - file: docker-default
