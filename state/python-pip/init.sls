pkg-deps:
  pkg.latest:
    - pkgs:
      - python-pip
      - python-dev
      - python-apt
      - libffi-dev
      - libssl-dev

docker-py-api:
  pip.installed:
    - name: docker-py == 0.5.0
    - require:
      - pkg: pkg-deps

python-etcd:
  pip.installed:
    - index_url: https://pypi.binstar.org/pypi/simple
    - require:
      - pkg: pkg-deps

python-cherrypy3:
  pkg.installed:
    - name: python-cherrypy3
    - require:
      - pkg: pkg-deps
