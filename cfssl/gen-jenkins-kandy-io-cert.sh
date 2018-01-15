#!/bin/bash -eu

## STEP 1: Generate a certificate and private key for jenkins.kandy.io
## STEP 2: Sign jenkins.kandy.io cert by the intermediate CA's private Key
docker run --rm -v $(pwd):/pad \
    -w /pad \
    cfssl/cfssl:1.2.0 \
    gencert \
    -ca ca/intermediate-ca.pem \
    -ca-key ca/intermediate-ca-key.pem \
    -config config/int-to-client-config.json \
    csr/jenkins-kandy-io-csr.json > /tmp/jenkins-kandy-io-out.json

cat /tmp/jenkins-kandy-io-out.json | \
docker run -i --rm -v $(pwd):/pad \
    -w /pad/issued-certs \
    --entrypoint=cfssljson cfssl/cfssl:1.2.0 \
    -bare jenkins.kandy.io

# Concat Intermediate CA's cert to jenkins.kandy.io's
cat ./issued-certs/jenkins.kandy.io.pem > /tmp/jenkins-kandy-io.pem
cat ./ca/intermediate-ca.pem >> /tmp/jenkins-kandy-io.pem
cat ./ca/root-ca.pem >> /tmp/jenkins-kandy-io.pem

sudo mv /tmp/jenkins-kandy-io.pem ./issued-certs/jenkins.kandy.io.pem

# remove the intermediate output file
rm -rf /tmp/jenkins-kandy-io-out.json
