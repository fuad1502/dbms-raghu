FROM postgres:16.1
COPY ./postgres/init.sql /docker-entrypoint-initdb.d/
