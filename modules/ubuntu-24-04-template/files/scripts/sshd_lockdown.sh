#!/bin/sh
set -eu

# sshd uses the first value that it reads, and it reads sshd_config.d in name
# order. "10-" sorts before "50-cloud-init.conf", which the installer can add.
printf '%s\n' \
  'TrustedUserCAKeys /etc/ssh/infisical_ca.pub' \
  'AuthorizedKeysFile none' \
  'PasswordAuthentication no' \
  'KbdInteractiveAuthentication no' \
  'PermitRootLogin no' > /etc/ssh/sshd_config.d/10-infisical.conf
chmod 0644 /etc/ssh/sshd_config.d/10-infisical.conf

# The checks read the values that sshd really uses. usepam must be yes: the PAM
# users have a locked password ("!"), and without PAM sshd refuses them.
sshd -t
sshd -T > /tmp/sshd-T.txt
for setting in \
  'trustedusercakeys /etc/ssh/infisical_ca.pub' \
  'authorizedkeysfile none' \
  'passwordauthentication no' \
  'kbdinteractiveauthentication no' \
  'permitrootlogin no' \
  'usepam yes'; do
  if ! grep -qx "$setting" /tmp/sshd-T.txt; then
    echo "sshd does not use: $setting"
    exit 1
  fi
done
rm -f /tmp/sshd-T.txt
echo 'sshd settings OK'

rm -f /home/automation/.ssh/authorized_keys
