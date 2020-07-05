# Derived from official mysql image (our base image)
FROM mysql:latest
MAINTAINER "moaz.refat@hotmail.com"
# Add a database
ENV MYSQL_DATABASE version
COPY ./sql-scripts/ /docker-entrypoint-initdb.d/
