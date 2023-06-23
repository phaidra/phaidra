FROM httpd:2.4.57-bookworm
COPY ./../image_configs/httpd.conf /usr/local/apache2/conf/httpd.conf
RUN mkdir /usr/local/apache2/conf/vhosts
EXPOSE 80
CMD ["httpd", "-D", "FOREGROUND"]
