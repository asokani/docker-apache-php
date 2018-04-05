function apacheRedirect(domains) {
    const firstDomain = domains.slice(0, 1);
    const restDomains = domains.slice(1);

    return `
<VirtualHost *:80>
    ServerName ${firstDomain}
    ${restDomains.length > 0 ? restDomains.map(value => "ServerAlias " + value).join("\n") : ''}
    
    DocumentRoot /var/app-cert

    RewriteEngine On
    RewriteCond %{REQUEST_URI} !^/.well-known/acme-challenge
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [L]        
</VirtualHost>
    `;
}

function apacheRedirectSSL(target, subdomains) {
    const firstDomain = subdomains.slice(0, 1);
    const restDomains = subdomains.slice(1);

    return `
<VirtualHost *:443>
    ServerName ${firstDomain}
    ${restDomains.length > 0 ? restDomains.map(value => "ServerAlias " + value).join("\n") : ''}
    
    DocumentRoot /var/app-cert

    <IfModule mod_ssl.c>
        SSLEngine on
        SSLCertificateFile /etc/secrets/letsencrypt/signed.crt
        SSLCertificateKeyFile /etc/secrets/letsencrypt/domain.key
    </IfModule>

    RedirectMatch 301 ^(.*)$ https://${target}%{REQUEST_URI}
</VirtualHost>
    `;
}

function apacheSSL(domains) {
    const firstDomain = domains.slice(0, 1);
    const restDomains = domains.slice(1);
    let config = '';

    if (restDomains.length > 0) {
        config += apacheRedirectSSL(firstDomain, restDomains);
    }

    config += `
<VirtualHost *:443>
    ServerName ${firstDomain}

    DocumentRoot /var/app

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    # Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains; preload"
    # Header always set X-Frame-Options DENY
    # Header always set X-Content-Type-Options nosniff

    <IfModule mod_ssl.c>
        SSLEngine on
        SSLCertificateFile /etc/secrets/letsencrypt/signed.crt
        SSLCertificateKeyFile /etc/secrets/letsencrypt/domain.key
    </IfModule>
</VirtualHost>    
    `    

    return config;
}

function create(domains) {
    let config = '';
    let flatDomains = [];

    for (let i = 0; i < domains.length; i++) {
        let currentDomains = domains[i];
    
        if (Array.isArray(currentDomains)) {
            config += apacheRedirect(currentDomains);
            config += apacheSSL(currentDomains);
        } else {
            flatDomains.push(currentDomains);
        }
    }

    if (flatDomains.length > 0) {
        config += apacheRedirect(flatDomains);
        config += apacheSSL(flatDomains);
    }

    return config;
}

module.exports = create;