#!/bin/sh
set -eu

install -o root -g root -m 0644 /tmp/infisical_ca.pub /etc/ssh/infisical_ca.pub
rm -f /tmp/infisical_ca.pub

if [ "$(ssh-keygen -l -f /etc/ssh/infisical_ca.pub | wc -l)" -ne 1 ]; then
  echo '/etc/ssh/infisical_ca.pub must hold exactly one key'
  exit 1
fi
ssh-keygen -l -f /etc/ssh/infisical_ca.pub
