#!/bin/bash

# Do some chef pre-work
/bin/mkdir -p /etc/chef
/bin/mkdir -p /var/lib/chef
/bin/mkdir -p /var/log/chef

cd /etc/chef/

# Install chef
curl -L https://omnitruck.chef.io/install.sh | bash || error_exit 'could not install chef'

# Add solsys cacert to cacert.pem
/bin/echo "Chef-Master SSL Certificate
=============================================
-----BEGIN CERTIFICATE-----
MIIEejCCA2KgAwIBAgIBADANBgkqhkiG9w0BAQsFADCBhTELMAkGA1UEBhMCVVMx
FjAUBgNVBAgTDU1hc3NhY2h1c2V0dHMxDzANBgNVBAcTBldvYnVybjETMBEGA1UE
ChMKU29sc3lzIEluYzEhMB8GCSqGSIb3DQEJARYSZGpraGFuODVAZ21haWwuY29t
MRUwEwYDVQQDFAwqLnNvbHN5cy5jb20wHhcNMTcwNDI3MDExNTI2WhcNMjcwNDI1
MDExNTI2WjCBhTELMAkGA1UEBhMCVVMxFjAUBgNVBAgTDU1hc3NhY2h1c2V0dHMx
DzANBgNVBAcTBldvYnVybjETMBEGA1UEChMKU29sc3lzIEluYzEhMB8GCSqGSIb3
DQEJARYSZGpraGFuODVAZ21haWwuY29tMRUwEwYDVQQDFAwqLnNvbHN5cy5jb20w
ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDhn8Gh46wPgnBQWsjL0IhP
iDCtxK/xlDA5lckp0ttzoISc7qqKjf4VXG7iLMrEcOktThHgrFy4wZxkEEdy3t5D
aNrV0yp/1tYCkmWSNrDoxZabNmlNUxetkFMudau+OtX4+D9Ngf9phxkDXdwuhvDl
qt/AdkCosdxmAM1ASCtuJwkEKu85GFS47hXKvJjYZEXHNEAUTD8wecm5NxZo5jnK
zMTwwKYxbYXw7Jh3Hg3n+yYi12rU5cnkvvqicQtqRwVQJKLbbKKm9HGFde/KEYaQ
hP0XuhJiT6RipfXRszjzIa0obh4XOArqWHtXPzCpliDYbYJZAgqJIr8whFcVgAn/
AgMBAAGjgfIwge8wHQYDVR0OBBYEFCNPeZxbE4Xx9Dv58Wyx4Jwwcs4oMIGyBgNV
HSMEgaowgaeAFCNPeZxbE4Xx9Dv58Wyx4Jwwcs4ooYGLpIGIMIGFMQswCQYDVQQG
EwJVUzEWMBQGA1UECBMNTWFzc2FjaHVzZXR0czEPMA0GA1UEBxMGV29idXJuMRMw
EQYDVQQKEwpTb2xzeXMgSW5jMSEwHwYJKoZIhvcNAQkBFhJkamtoYW44NUBnbWFp
bC5jb20xFTATBgNVBAMUDCouc29sc3lzLmNvbYIBADAMBgNVHRMEBTADAQH/MAsG
A1UdDwQEAwIBBjANBgkqhkiG9w0BAQsFAAOCAQEARTLkVDxwf9Rw3TYaawtRpGoH
Tprnpf7wJYhN0R3xf+y0s8DZQvm7exdg7W0baZxt66KTyJ+Y8IgmYd6q+lGtdaN8
gs69Qq2XX+9xnNbYR+mCCBh4m+NHu4ppjP7OhkRTgHNvfxZ20ru/jT/gpQFK4qhi
IicuVr9SwHzaikK3RBFo76PHv7qIMIUg68E35yPTaVPzezhYvQD2Zi6c6LN6p05B
IvJVoTncJsITpDPOs8O42dzQwZE2xhRAW6YcXrrMNFAoMBz6Wm9cxJpiy3Y8NK0H
IHBUVPNco0ziX2hWtCBFER2rtYtaMaOv4NiALyYpT/8PQsXNCF/ze+cEZwiSjg==
-----END CERTIFICATE-----" >> /opt/chef/embedded/ssl/certs/cacert.pem

# Create validator.pem
/bin/cp bootstrap.pem /etc/chef/bootstrap.pem

# Create first-boot.json
cat > "/etc/chef/first-boot.json" << EOF
{
   "run_list" :[
   "role[base_configuration]"
   ]
}
EOF

NODE_NAME=node-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)

# Create client.rb
/bin/echo 'log_location     STDOUT' >> /etc/chef/client.rb
/bin/echo -e "chef_server_url  \"https://Chef-Master.solsys.com/organizations/solsys\"" >> /etc/chef/client.rb
/bin/echo -e "validation_client_name \"bootstrap\"" >> /etc/chef/client.rb
/bin/echo -e "validation_key \"/etc/chef/bootstrap.pem\"" >> /etc/chef/client.rb
/bin/echo -e "node_name  \"${NODE_NAME}\"" >> /etc/chef/client.rb

sudo chef-client -j /etc/chef/first-boot.json