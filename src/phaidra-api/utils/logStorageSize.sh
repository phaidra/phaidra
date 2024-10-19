#!/bin/bash

exec 2>&1

source /home/phaidev/work/perl5/etc/bashrc

perlbrew exec -q perl /usr/local/phaidra/phaidra-api/utils/logStorageSize.pl
