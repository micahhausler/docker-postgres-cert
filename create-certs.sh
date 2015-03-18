#!/bin/bash

if [ -n $DOCKER ]; then
    cd /opt/
fi

# demoCA setup
DEMOCA_DIR="demoCA"
mkdir -p $DEMOCA_DIR/{certs,crl,newcerts,private}
PRIVATE_DIR="$DEMOCA_DIR/private"
chmod 700 $DEMOCA_DIR/private
touch $DEMOCA_DIR/index.txt
touch $DEMOCA_DIR/index.txt.attr
echo 1000 > $DEMOCA_DIR/serial

CA_KEY="${PRIVATE_DIR}/cakey.pem"
CA_CERT="${PRIVATE_DIR}/cacert.pem"

# CREATE CA_KEY
if [ ! -f ${CA_KEY} ]; then
    echo "############################"
    echo "# Creating CA cert and key #"
    echo "############################"
    openssl genrsa -out ${CA_KEY} 4096;
    chmod 400  ${CA_KEY};

    openssl req \
        -new \
        -x509 \
        -days 3650 \
        -key ${CA_KEY} \
        -subj "/C=US/ST=Tennessee/L=Chattanooga/O=Example Company/OU=CA/CN=ca.example.com/emailAddress=admin@example.com" \
        -sha256 \
        -extensions v3_ca \
        -out ${CA_CERT};
fi


LOCAL_KEY="server.key"
LOCAL_CERT="server.crt"
LOCAL_CSR="server.csr"

echo "###############################"
echo "# Creating local key and CSR #"
echo "##############################"
# Create the user-end key
if [ ! -f ${LOCAL_KEY} ]; then
    openssl genrsa -out ${LOCAL_KEY} 4096;
fi

# Create the user-end request
if [ ! -f ${LOCAL_CSR} ]; then
openssl req \
    -new \
    -sha256 \
    -subj "/C=US/ST=Tennessee/L=Chattanooga/O=Example Company/OU=postgres/CN=postgres.example.com/emailAddress=admin@example.com" \
    -key ${LOCAL_KEY} \
    -out ${LOCAL_CSR}
fi

echo "##################################"
echo "# Signing local CSR with CA cert #"
echo "##################################"
# sign the req with the CA cert
openssl ca \
    -verbose \
    -batch \
    -startdate 150101010101Z \
    -enddate 150202020202Z \
    -cert ${CA_CERT} \
    -md sha256 \
    -in ${LOCAL_CSR} \
    -out ${LOCAL_CERT}

rm ${LOCAL_CSR}

# move files if in docker
if [ -n $DOCKER ]; then
    echo "##################################"
    echo "# Move key/cert to $PGDATA #"
    echo "##################################"

    mv $LOCAL_KEY $PGDATA/$LOCAL_KEY
    chmod 600 $PGDATA/$LOCAL_KEY
    chown postgres:postgres $PGDATA/${LOCAL_KEY}

    mv $LOCAL_CERT $PGDATA/$LOCAL_CERT
    chmod 600 $PGDATA/$LOCAL_CERT
    chown postgres:postgres $PGDATA/${LOCAL_CERT}
fi
