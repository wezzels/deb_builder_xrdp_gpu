#!/bin/bash



#novnc/noVNC-1.3.0/utils/novnc_proxy --vnc localhost:5902 --cert `pwd`/ssl/alt_cert.pem --key `pwd`/ssl/alt_key.pem --ssl-only



./novnc/noVNC-1.3.0/utils/novnc_proxy --listen 127.0.0.1:6080 --vnc 127.0.0.1:5900 --cert /home/wez/test_build/ssl/alt_cert.pem --key /home/wez/test_build/ssl/alt_key.pem --ssl-only &
./novnc/noVNC-1.3.0/utils/novnc_proxy --listen 127.0.0.1:6081 --vnc 127.0.0.1:5901 --cert /home/wez/test_build/ssl/alt_cert.pem --key /home/wez/test_build/ssl/alt_key.pem --ssl-only &
./novnc/noVNC-1.3.0/utils/novnc_proxy --listen 127.0.0.1:6082 --vnc 127.0.0.1:5902 --cert /home/wez/test_build/ssl/alt_cert.pem --key /home/wez/test_build/ssl/alt_key.pem --ssl-only &
./novnc/noVNC-1.3.0/utils/novnc_proxy --listen 127.0.0.1:6083 --vnc 127.0.0.1:5903 --cert /home/wez/test_build/ssl/alt_cert.pem --key /home/wez/test_build/ssl/alt_key.pem --ssl-only &
./novnc/noVNC-1.3.0/utils/novnc_proxy --listen 127.0.0.1:6084 --vnc 127.0.0.1:5904 --cert /home/wez/test_build/ssl/alt_cert.pem --key /home/wez/test_build/ssl/alt_key.pem --ssl-only &
./novnc/noVNC-1.3.0/utils/novnc_proxy --listen 127.0.0.1:6085 --vnc 127.0.0.1:5905 --cert /home/wez/test_build/ssl/alt_cert.pem --key /home/wez/test_build/ssl/alt_key.pem --ssl-only &
./novnc/noVNC-1.3.0/utils/novnc_proxy --listen 127.0.0.1:6086 --vnc 127.0.0.1:5906 --cert /home/wez/test_build/ssl/alt_cert.pem --key /home/wez/test_build/ssl/alt_key.pem --ssl-only &
./novnc/noVNC-1.3.0/utils/novnc_proxy --listen 127.0.0.1:6087 --vnc 127.0.0.1:5907 --cert /home/wez/test_build/ssl/alt_cert.pem --key /home/wez/test_build/ssl/alt_key.pem --ssl-only &
./novnc/noVNC-1.3.0/utils/novnc_proxy --listen 127.0.0.1:6088 --vnc 127.0.0.1:5908 --cert /home/wez/test_build/ssl/alt_cert.pem --key /home/wez/test_build/ssl/alt_key.pem --ssl-only &
./novnc/noVNC-1.3.0/utils/novnc_proxy --listen 127.0.0.1:6089 --vnc 127.0.0.1:5909 --cert /home/wez/test_build/ssl/alt_cert.pem --key /home/wez/test_build/ssl/alt_key.pem --ssl-only &
