cp /ssl/fullchain.pem /usr/local/apache2/conf/server.crt
cp /ssl/privkey.pem /usr/local/apache2/conf/server.key
httpd-foreground
