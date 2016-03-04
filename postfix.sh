#!/bin/bash
cp /etc/services /etc/hosts /etc/resolv.conf /etc/localtime /var/spool/postfix/etc/
exec 1>&2
exec /usr/lib/postfix/master

