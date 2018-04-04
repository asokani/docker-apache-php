#!/usr/bin/node

const path = require("path");
const fs = require("fs");
const childProcess = require("child_process");

const letsencryptDir = "/etc/secrets/letsencrypt";
const configDir = "/etc/secrets/_config/apache-php";

const apacheConf = "/etc/apache2/sites-enabled/app.conf";

const config = JSON.parse(fs.readFileSync(path.join(configDir, "config.json"), "utf8"));
const domainKey = path.join(letsencryptDir, "domain.key");
const domainCsr = path.join(letsencryptDir, "domain.csr");

childProcess.execSync(`
if [ ! -f  ${domainKey} ]; then
  openssl genrsa 4096 > ${domainKey}
fi
`, {stdio:[0, 1, 2]});

const domainsString = JSON.stringify(config.domains);
const domainsFile = path.join(letsencryptDir, "domains.json");

if (!fs.existsSync(domainsFile) || domainsString !== fs.readFileSync(domainsFile, "utf8")) {
    // domain have changed -> generate csr
    childProcess.execSync(
        `/bin/bash -c 'openssl req -new -sha256 -key ${domainKey} -subj "/" -reqexts SAN ` +
        `-config <(cat /etc/ssl/openssl.cnf ` +
        `<(printf "[SAN]\nsubjectAltName=${config.domains.map(value=>'DNS:' + value).join(",")}")) > ${domainCsr}'`
    , {stdio:[0, 1, 2]});

    fs.writeFileSync(domainsFile, domainsString, "utf8");
}

const firstDomain = config.domains.slice(0, 1);
const restDomains = config.domains.slice(1);

if (!fs.existsSync(apacheConf)) {
    const conf = `
    <VirtualHost *:80>
        ServerName ${firstDomain}
        ${restDomains.length > 0 ? restDomains.map(value => "ServerAlias " + value).join("\n") : ''}
        DocumentRoot /var/app-cert

        <Directory /var/app-cert/.well-known/acme-challenge>
            AllowOverride All
            Options Indexes FollowSymLinks
            Require all granted
        </Directory>

        RewriteEngine On
        RewriteCond %{REQUEST_URI} !^/.well-known/acme-challenge
        RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [L]
    </VirtualHost>
    <VirtualHost *:443>
        ServerName adminer.merry.netfinity.cz

        DocumentRoot /var/app

        <Directory /var/app>
            AllowOverride All
            Options Indexes FollowSymLinks
            Require all granted
        </Directory>

        # Header always set X-Frame-Options DENY
        # Header always set X-Content-Type-Options nosniff

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined


        <IfModule mod_ssl.c>
            SSLEngine on
            SSLCertificateFile /etc/secrets/letsencrypt/signed.crt
            SSLCertificateKeyFile /etc/secrets/letsencrypt/domain.key
        </IfModule>

        # Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains; preload"
    </VirtualHost>
    `;

    fs.writeFileSync(apacheConf, conf, "utf8");
}

