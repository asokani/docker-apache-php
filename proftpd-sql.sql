DROP TABLE IF EXISTS ftpgroup;
DROP TABLE IF EXISTS ftpquotalimits;
DROP TABLE IF EXISTS ftpquotatallies;
DROP TABLE IF EXISTS ftpuser;

CREATE TABLE "ftpgroup" (
  "groupname" varchar(16) NOT NULL DEFAULT '',
  "gid" smallint(6) NOT NULL DEFAULT '5500',
  "members" varchar(16) NOT NULL DEFAULT ''
);
CREATE TABLE "ftpquotalimits" (
  "name" varchar(30) DEFAULT NULL,
  "quota_type" text  NOT NULL DEFAULT 'user',
  "per_session" text  NOT NULL DEFAULT 'false',
  "limit_type" text  NOT NULL DEFAULT 'soft',
  "bytes_in_avail" int(10)  NOT NULL DEFAULT '0',
  "bytes_out_avail" int(10)  NOT NULL DEFAULT '0',
  "bytes_xfer_avail" int(10)  NOT NULL DEFAULT '0',
  "files_in_avail" int(10)  NOT NULL DEFAULT '0',
  "files_out_avail" int(10)  NOT NULL DEFAULT '0',
  "files_xfer_avail" int(10)  NOT NULL DEFAULT '0'
);
CREATE TABLE "ftpquotatallies" (
  "name" varchar(30) NOT NULL DEFAULT '',
  "quota_type" text  NOT NULL DEFAULT 'user',
  "bytes_in_used" int(10)  NOT NULL DEFAULT '0',
  "bytes_out_used" int(10)  NOT NULL DEFAULT '0',
  "bytes_xfer_used" int(10)  NOT NULL DEFAULT '0',
  "files_in_used" int(10)  NOT NULL DEFAULT '0',
  "files_out_used" int(10)  NOT NULL DEFAULT '0',
  "files_xfer_used" int(10)  NOT NULL DEFAULT '0'
);
CREATE TABLE "ftpuser" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "userid" varchar(32) NOT NULL DEFAULT '',
  "passwd" varchar(32) NOT NULL DEFAULT '',
  "uid" smallint(6) NOT NULL DEFAULT '5500',
  "gid" smallint(6) NOT NULL DEFAULT '5500',
  "homedir" varchar(255) NOT NULL DEFAULT '',
  "shell" varchar(16) NOT NULL DEFAULT '/bin/false',
  "count" int(11) NOT NULL DEFAULT '0',
  "accessed" datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  "modified" datetime NOT NULL DEFAULT '0000-00-00 00:00:00'
);

CREATE INDEX "ftpgroup_groupname" ON "ftpgroup" ("groupname");
CREATE INDEX "ftpuser_userid" ON "ftpuser" ("userid");
