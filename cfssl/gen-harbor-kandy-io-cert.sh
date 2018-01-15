#!/bin/bash -eu

## STEP 1: Generate a certificate and private key for harbor.kandy.io
## STEP 2: Sign harbor.kandy.io cert by the intermediate CA's private Key
docker run --rm -v $(pwd):/pad \
    -w /pad \
    cfssl/cfssl:1.2.0 \
    gencert \
    -ca ca/intermediate-ca.pem \
    -ca-key ca/intermediate-ca-key.pem \
    -config config/int-to-client-config.json \
    csr/harbor-kandy-io-csr.json > /tmp/harbor-kandy-io-out.json

cat /tmp/harbor-kandy-io-out.json | \
docker run -i --rm -v $(pwd):/pad \
    -w /pad/issued-certs \
    --entrypoint=cfssljson cfssl/cfssl:1.2.0 \
    -bare harbor.kandy.io

# Concat Intermediate CA's cert to harbor.kandy.io's
cat ./issued-certs/harbor.kandy.io.pem > /tmp/harbor-kandy-io.pem
cat ./ca/intermediate-ca.pem >> /tmp/harbor-kandy-io.pem
cat ./ca/root-ca.pem >> /tmp/harbor-kandy-io.pem

sudo mv /tmp/harbor-kandy-io.pem ./issued-certs/harbor.kandy.io.pem

# remove the intermediate output file
rm -rf /tmp/harbor-kandy-io-out.json
