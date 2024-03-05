if [[ ! -f /var/log/phaidra/api.log ]]
then
    ln -sF /proc/1/fd/1 /var/log/phaidra/api.log
fi
hypnotoad -f phaidra-api.cgi
