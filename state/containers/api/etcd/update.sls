# Set and change api's in etcd
#
# 1. Check new still uncative containers if failer stop
# 2. Set new/update containers in etcd
# 3. Set new container color to be active
#
{% set unactive = salt['pillar.get']('containers:api:unactive', '') -%}
{% set active = salt['pillar.get']('containers:api:active', '') -%}
{% set tag = salt['pillar.get']('containers:api:tag:new', '') -%}
{% set amount = salt['pillar.get']('containers:api:amount:new', '') -%}

{% for no in range(0, amount|int + 1) -%}
{%- if unactive == 'green' -%}
{%- set cid = salt['docker.inspect_container']('green-node-demo')['id'] -%}
{%- set container = salt['docker.inspect_container']('green-node-demo-' + no|string)['out']['NetworkSettings']['Ports']['8080/tcp'][0] -%}
{%- elif unactive == 'blue'  -%}
{%- set cid = salt['docker.inspect_container']('blue-node-demo')['id'] -%}
{%- set container = salt['docker.inspect_container']('blue-node-demo-' + no|string)['out']['NetworkSettings']['Ports']['8080/tcp'][0] -%}
{%- endif -%}

# 1. Check new still uncative containers if failer stop
unactive-healtcheck-{{ no }}:
  cmd.run:
    - name: 'curl -f http://{{ container['HostIp'] }}:{{ container['HostPort'] }}/'
    - failhard: True

# 2. Set new/update containers in etcd
set-etcd-for-api-{{ no }}:
  module.run:
    - name: etcd.set
    - key: /salt/shared/containers/api/{{ grains['id'] }}/{{ cid }}/{{ no }}/network
    - value: "{{ container['HostIp'] }}:{{ container['HostPort'] }}"
    - profile: etcd_config
    - reload_pillar: True
{% endfor -%}

# 3. Set new container color to be active
set-etcd-unactive:
  module.run:
    - name: etcd.set
    - key: /salt/shared/containers/api/unactive
    - value: "{{ active }}"
    - profile: etcd_config
    - reload_pillar: True

set-etcd-active:
  module.run:
    - name: etcd.set
    - key: /salt/shared/containers/api/active
    - value: "{{ unactive }}"
    - profile: etcd_config
    - reload_pillar: True

set-etcd-tag-current:
  module.run:
    - name: etcd.set
    - key: /salt/shared/containers/api/tag/current
    - value: "{{ tag }}"
    - profile: etcd_config
    - reload_pillar: True

set-etcd-amount-current:
  module.run:
    - name: etcd.set
    - key: /salt/shared/containers/api/amount/current
    - value: "{{ amount }}"
    - profile: etcd_config
    - reload_pillar: True
