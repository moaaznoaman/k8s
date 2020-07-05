# Pull base image 
FROM python:3.7

MAINTAINER "moaz.refat@hotmail.com"
COPY . /app
WORKDIR /app
RUN apt-get update \
    && apt-get install -y \
        vim
RUN pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["main.py"]