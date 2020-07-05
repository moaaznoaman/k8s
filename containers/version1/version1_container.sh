#!/bin/bash

docker build -t version-v1 .
docker tag version-v1 moazrefat/app:version-v1
docker push moazrefat/app:version-v1