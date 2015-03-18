#!/bin/bash
cat /etc/postgresql-common/ssl.conf | tee -a $PGDATA/postgresql.conf
