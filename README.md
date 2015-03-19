# Docker Postgres Demo with Certificate
This repo is for running a Docker postgres image with SSL based on the library
[postgres 9.4 image](https://github.com/docker-library/postgres).

## Rational
I created this to see application behavior with an invalid/out of date
certificate on the postgres server. You can modify the certificate approval
parameters in the file `create-certs.sh`. For more information about approving
a CSR, check the openssl help output by running:
```
openssl ca -h
```

## Build
To build yourself, I'm assuming you have docker installed. You may want to do
this if you don't use postgres 9.3 or 9.4
```
git clone git@github.com:micahhausler/docker-postgres-cert.git
cd docker-postgres-cert/
docker build -t $(whoami)/postgres-ssl .
```

## Download
```
docker pull micahhausler/postgres-outdated-ssl:9.3
# or
docker pull micahhausler/postgres-outdated-ssl:9.4
```

## Use
First get postgres up and running:
```
docker run -t --name postgres -h postgres -p 5432:5432 $(whoami)/postgres-ssl
```

Then connect with the proper `sslmode` parameter that your client uses to
connect to postgres.
([libpq docs](http://www.postgresql.org/docs/9.4/static/libpq-connect.html#LIBPQ-CONNECT-SSLMODE))

* disable - **will not use ssl**
* allow - **will revert to non-ssl mode with an outdated cert**
* prefer - **will revert to non-ssl mode with an outdated cert**
* require - **will fail with an outdated cert**
* verify-ca - **will fail with an outdated cert**
* verify-full- **will fail with an outdated cert**

```
psql "sslmode=prefer host=$(boot2docker ip) port=5432 user=postgres"
```
or
```
export PGSSLMODE="prefer"
psql -U postgres -h $(boot2docker ip) -p 5432
```

## MIT License
See the `LICENSE` file for full information.
