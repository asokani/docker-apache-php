#!/bin/bash
SIGNED_CRT="$(mktemp)"
INTERMEDIATE="$(mktemp)"
sudo -u acme date >> /var/log/acme/acme_tiny.log
sudo -u acme /usr/bin/python /opt/acme_tiny.py --account-key /etc/secrets-global/letsencrypt/letsencrypt-account.key --csr /etc/secrets/letsencrypt/domain.csr --acme-dir /var/app-cert/.well-known/acme-challenge > $SIGNED_CRT 2>> /var/log/acme/acme_tiny.log
wget -q -O - https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.pem > $INTERMEDIATE
if [ -s $SIGNED_CRT ] && /usr/bin/openssl verify -CAfile $INTERMEDIATE $SIGNED_CRT
then
    # for nginx cat $SIGNED_CRT $INTERMEDIATE > /etc/secrets/letsencrypt/chained.csr
    chmod 400 $SIGNED_CRT $INTERMEDIATE
    mv $INTERMEDIATE /etc/secrets/letsencrypt/intermediate.pem
    mv $SIGNED_CRT /etc/secrets/letsencrypt/signed.crt
fi
rm $INTERMEDIATE $SIGNED_CRT
/usr/sbin/apache2ctl graceful