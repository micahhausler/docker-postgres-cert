# Docker Postgres Demo with Certificate
This repo is for running a Docker postgres image with SSL based on the library
postgres image.

## Rational
I created this to see application behavior with an invalid/out of date
certificate. You can modify the certificate approval parameters in the file
`create-certs.sh`. For more information about approving a CSR, check the
openssl help output by running:
```
openssl ca -h
```

## Build
To build, I'm assuming you have docker installed.
```
git clone git@github.com:micahhausler/docker-postgres-cert.git
cd docker-postgres-cert/
docker buitd -t $(whoami)/postgres-ssl .
```

## Use
```
docker run -d --name postgres -h postgres -p 5432:5432 $(whoam)/postgres-ssl
psql -h $(boot2docker ip) -U postgres -p 5432
```

## MIT License
See the `LICENSE` file for full information.
