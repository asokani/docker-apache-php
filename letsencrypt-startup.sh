#!/bin/bash

python /opt/acme_tiny.py --ca "https://acme-staging.api.letsencrypt.org" --account-key /etc/secrets/letsencrypt/letsencrypt.key --csr /etc/secrets/letsencrypt/app.csr --acme-dir /app-cert/.well-known/acme-challenge  > /etc/secrets/letsencrypt/signed.crt
wget -O - https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.pem > /etc/secrets/letsencrypt/intermediate.pem
cat /etc/secrets/letsencrypt/signed.crt /etc/secrets/letsencrypt/intermediate.pem > /etc/secrets/letsencrypt/chained.pem
