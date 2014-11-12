#!/bin/sh
psql -U postgres -W -h localhost -d acme -f acme_dump.sql