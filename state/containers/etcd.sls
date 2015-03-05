{% set hostip = grains['ip_interfaces']['eth0'][0] %}
etcd-image:
   docker.pulled:
     - name: bloglovin/etcd:latest
     - require_in: etcd-container
     - force: True

etcd-container:
  docker.installed:
    - name: etcd01
    - hostname: etcd01
    - image: bloglovin/etcd:latest
    - ports:
        - "4001/tcp"
        - "7001/tcp"
    - require_in: etcd

etcd:
  docker.running:
    - container: etcd01
    - port_bindings:
        "4001/tcp":
            HostIp: "{{ hostip }}"
            HostPort: "4001"
        "7001/tcp":
            HostIp: "{{ hostip }}"
            HostPort: "7001"
