
#vnc
NOVNC_HOME=./novnc
if [ ! -d $NOVNC_HOME ]; then
    mkdir $NOVNC_HOME
    wget https://github.com/novnc/noVNC/archive/v1.3.0.zip
    unzip v1.3.0.zip -d $NOVNC_HOME
    chown -R $DEFAULT_USER:$DEFAULT_USER $NOVNC_HOME
    rm -f v1.3.0.zip
fi

cp novnc/noVNC-1.3.0/vnc_lite.html novnc/noVNC-1.3.0/index.html

mkdir -p ssl 

openssl req -newkey rsa:4096 \
            -x509 \
            -sha256 \
            -days 3650 \
            -nodes \
            -out ssl/cert.pem \
            -keyout ssl/key.pem \
            -subj "/C=US/ST=New Mexico/L=Albuquerque/O=Security/OU=Bedim/CN=*.bedim.us"

openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
	    -keyout ssl/alt_key.pem -out ssl/alt_cert.pem \
	    -subj "/C=US/ST=New Mexico/L=Albuquerque/O=Security/OU=Bedim/CN=*.bedim.us" \
	    -addext "subjectAltName=DNS:black,DNS:bedim.us,DNS:black.bedim.us,IP:192.168.1.196"

echo "novnc/noVNC-1.3.0/utils/novnc_proxy --vnc localhost:5902 --cert `pwd`/ssl/alt_cert.pem --key `pwd`/ssl/alt_key.pem --ssl-only"
