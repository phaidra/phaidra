FROM perl:5.32

RUN cpan install MongoDB  # Install the MongoDB Perl driver

WORKDIR /app
COPY container_init/mongodb/session_cleanup.pl /app/session_cleanup.pl

CMD ["perl", "/app/session_cleanup.pl"]
