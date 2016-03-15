#!/bin/bash
if [ ! -f /etc/secrets/letsencrypt/signed.crt ]; then
	cd /var/app-cert/
	python -c 'import BaseHTTPServer as bhs, SimpleHTTPServer as shs; bhs.HTTPServer(("0.0.0.0", 80), shs.SimpleHTTPRequestHandler).serve_forever()' > /dev/null 2>&1 &
	/etc/cron.monthly/letsencrypt.sh
	pkill -f SimpleHTTPServer
fi

