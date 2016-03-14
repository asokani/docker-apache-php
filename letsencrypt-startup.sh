#!/bin/bash
cd /app-cert/
python -c 'import BaseHTTPServer as bhs, SimpleHTTPServer as shs; bhs.HTTPServer(("0.0.0.0", 80), shs.SimpleHTTPRequestHandler).serve_forever()' > /dev/null 2>&1 &
python /opt/acme_tiny.py --account-key /etc/secrets/letsencrypt/letsencrypt-account.key --csr /etc/secrets/letsencrypt/domain.csr --acme-dir /app-cert/.well-known/acme-challenge  > /etc/secrets/letsencrypt/signed.crt
wget -q -O - https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.pem > /etc/secrets/letsencrypt/intermediate.pem
cat /etc/secrets/letsencrypt/signed.crt /etc/secrets/letsencrypt/intermediate.pem > /etc/secrets/letsencrypt/chained.pem
pkill -f SimpleHTTPServer
