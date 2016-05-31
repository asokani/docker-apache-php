#!/bin/bash
set -e 
source /etc/apache2/envvars 
exec /usr/sbin/apache2 -f /etc/apache2/apache2.conf -DNO_DETACH