#!/bin/bash
docker build -t employee .
docker tag employee moazrefat/app:employee
docker push moazrefat/app:employee