FROM ghcr.io/ldapaccountmanager/lam:9.1
RUN chmod g+w /etc/php/8.2/apache2 &&\
 chmod g+rw /etc/ldap-account-manager &&\
 chmod g+rw /etc/ldap-account-manager/config.cfg &&\
 chmod g+w /var/run/apache2 &&\
 chown -R :root /var/log/apache2 &&\
 chmod -R g+rw /var/log/apache2 &&\
 chmod -R g+rwx /var/lib/ldap-account-manager/config
RUN sed -i s/80/8080/g /etc/apache2/sites-available/lam.conf && echo "Listen 8080" > /etc/apache2/ports.conf
