#!/bin/sh

echo "Generating certificates for use with CircleCI, press enter to continue"
read check1
openssl genrsa -des3 -passout pass:x -out server.pass.key 2048
openssl rsa -passin pass:x -in server.pass.key -out server.key
rm server.pass.key
echo "Now generating the server key, when prompted for a password, press enter to continue"
read check2
openssl req -new -key server.key -out server.csr
echo "Now generating the certificates, press enter to continue"
openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt
echo "Key will now be encoded in BASE64 and displayed, use the output for the value of SFDC_SERVER_KEY environnment variable"
echo "/n"
base64 server.key
echo "Now cleaning up, keys will be deleted"
rm server.csr
rm server.key
echo "Certificate and key generation complete, please add server.crt to your OAuth connected app in salesforce"