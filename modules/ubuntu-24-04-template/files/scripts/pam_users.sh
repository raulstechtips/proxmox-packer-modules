#!/bin/sh
set -eu

# --disabled-password locks the password ("!" in /etc/shadow). With UsePAM yes
# (the Ubuntu default), sshd does not refuse a locked account, so a certificate
# login still works. Do not set an expiry date: an expired account refuses
# certificates too.
addgroup --system pam-admins
adduser --disabled-password --gecos '' pam-user
adduser --disabled-password --gecos '' pam-admin
adduser pam-admin pam-admins

# sudo ignores a file in sudoers.d with a dot in its name or a mode other than
# 0440, and gives no warning (PAM runbook, R16). So set the owner and the mode
# first, and check the file before it goes into sudoers.d.
printf '%s\n' '%pam-admins ALL=(ALL:ALL) NOPASSWD:ALL' > /tmp/60-infisical-pam-admins
chown root:root /tmp/60-infisical-pam-admins
chmod 0440 /tmp/60-infisical-pam-admins
visudo -cf /tmp/60-infisical-pam-admins
mv /tmp/60-infisical-pam-admins /etc/sudoers.d/60-infisical-pam-admins
visudo -c

if ! sudo -l -U pam-admin | grep -q 'NOPASSWD: ALL'; then
  echo 'pam-admin must have NOPASSWD: ALL'
  exit 1
fi
if sudo -l -U pam-user | grep -q NOPASSWD; then
  echo 'pam-user must not have sudo'
  exit 1
fi

id pam-user
id pam-admin
