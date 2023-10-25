cp /mnt/startup/conf/phaidra-ssl.conf /usr/local/apache2/conf/httpd.conf
cp /mnt/startup/conf/fullchain.pem /usr/local/apache2/conf/server.crt
cp /mnt/startup/conf/privkey.pem /usr/local/apache2/conf/server.key
httpd-foreground
