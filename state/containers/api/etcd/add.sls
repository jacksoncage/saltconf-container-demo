# Set/change danamic in etcd
#
# 1. Set current tag
# 2. Set new tag
# 3. Set current amount
# 4. Set new amount
# 5. Set image
#
{% set tagcurrent = salt['pillar.get']('containers:api:tag:current', '') %}
{% set tagnew = salt['pillar.get']('containers:imagetag', '') %}
{% set amountcurrent = salt['pillar.get']('containers:api:amount:current', '') %}
{% set amountnew = salt['pillar.get']('containers:amount', '') %}
{% set name = salt['pillar.get']('containers:name', '') %}
{% set container = salt['pillar.get']('containers:container', '') %}
{% set image = salt['pillar.get']('containers:image', '') %}

# 1. Set current tag
set-etcd-tag-last:
  module.run:
    - name: etcd.set
    - key: /salt/shared/containers/api/tag/last
    - value: "{{ tagcurrent }}"
    - profile: etcd_config
    - reload_pillar: True

# 2. Set new tag
set-etcd-tag-new:
  module.run:
    - name: etcd.set
    - key: /salt/shared/containers/api/tag/new
    - value: "{{ tagnew }}"
    - profile: etcd_config
    - reload_pillar: True

# 3. Set current amount
set-etcd-amount-last:
  module.run:
    - name: etcd.set
    - key: /salt/shared/containers/api/amount/last
    - value: {{ amountcurrent }}
    - profile: etcd_config
    - reload_pillar: True

# 4. Set new amount
set-etcd-amount-new:
  module.run:
    - name: etcd.set
    - key: /salt/shared/containers/api/amount/new
    - value: {{ amountnew }}
    - profile: etcd_config
    - reload_pillar: True

# 5. Set image
set-etcd-image:
  module.run:
    - name: etcd.set
    - key: /salt/shared/containers/api/image
    - value: "{{ image }}"
    - profile: etcd_config
    - reload_pillar: True

# 5. Set name
set-etcd-name:
  module.run:
    - name: etcd.set
    - key: /salt/shared/containers/api/name
    - value: "{{ name }}"
    - profile: etcd_config
    - reload_pillar: True
