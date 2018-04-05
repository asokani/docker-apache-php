#!/usr/bin/node

const path = require("path");
const fs = require("fs");
const childProcess = require("child_process");
const apacheCreate = require("./apache-conf-create");
 
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
    let flattenedDomains = []
    for (let i = 0; i < config.domains.length; i++) {
        flattenedDomains = flattenedDomains.concat(config.domains[i]);
    }
    childProcess.execSync(
        `/bin/bash -c 'openssl req -new -sha256 -key ${domainKey} -subj "/" -reqexts SAN ` +
        `-config <(cat /etc/ssl/openssl.cnf ` +
        `<(printf "[SAN]\nsubjectAltName=${flattenedDomains.map(value=>'DNS:' + value).join(",")}")) > ${domainCsr}'`
    , {stdio:[0, 1, 2]});

    fs.writeFileSync(domainsFile, domainsString, "utf8");
}

if (!fs.existsSync(apacheConf)) {
    const conf = apacheCreate(config.domains)

    fs.writeFileSync(apacheConf, conf, "utf8");
}

