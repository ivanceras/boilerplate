Boilerplate
===========

Boilerplate code using ivanceras orm

```bash

git clone https://github.com/ivanceras/boilerplate

```


Create a database

```bash
sudo su postgres
psql

ALTER ROLE postgres with password 'p0stgr3s'

CREATE DATABASE acme WITH OWNER postgres ENCODING 'utf8';

```

```bash

cd boilerplate/src/main/resources
psql -U postgres -W -h localhost -d acme -f acme_dump.sql

```
