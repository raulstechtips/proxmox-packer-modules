#cloud-config
autoinstall:
  version: 1
  locale: en_US
  keyboard:
    layout: us
  updates: security
  apt:
    disable_suites: [security]
  ssh:
    install-server: true
    allow-pw: false
    disable_root: true
    ssh_quiet_keygen: true
    allow_public_ssh_keys: true
  packages:
    - qemu-guest-agent
    - sudo
    - net-tools
    - apache2-utils
    - python3-netaddr
  storage:
    layout:
      name: direct
    swap:
      size: 0
  user-data:
    package_upgrade: true
    timezone: America/New_York
    users:
      - name: automation
        groups: [adm, sudo]
        lock-passwd: true
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${build_ssh_public_key}
