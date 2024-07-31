FROM testuser34/api-base:latest
ADD ../src/phaidra-api /usr/local/phaidra/phaidra-api
RUN ln -sF /proc/1/fd/1 /var/log/phaidra/api.log
