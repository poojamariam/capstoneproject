# Create rootCA key
openssl genrsa -out rootCA.key 4096

# Create and self sign the Root Certificate
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt

# Create the certificate key
openssl genrsa -out capstone.com.key 2048

# Create configuration file for wildcard cert
$ cat >> capstone.com.conf  
ts = 2048  
prompt = no  
default_md = sha256  
x509_extensions = v3_req  
distinguished_name = dn  
req_extensions = v3_req  
copy_extensions = copy  
  
[dn]  
C = CA  
ST = Ontario  
L = Toronto  
O = Capstone Inc  
OU = IT  
CN = capstone.com  
  
[v3_req]  
subjectAltName = @alt_names  
  
[alt_names]  
DNS.1 = capstone.com  
DNS.2 = *.capstone.com  
  
# Create the signing (csr)
openssl req -config capstone.com.conf -new -key capstone.com.key -out capstone.com.csr -verbose

# Create extfile
cat >> extfile.conf  
authorityKeyIdentifier=keyid,issuer  
basicConstraints=CA:FALSE  
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment  
subjectAltName = @alt_names  
  
[alt_names]  
DNS.1 = capstone.com  
DNS.2 = *.capstone.com  
  
# Sign the certificate for capstone.com
openssl x509 -req -in capstone.com.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out capstone.com.crt -days 500 -sha256 -extfile extfile.conf
