#!/bin/bash

docker build -t version-v3 .
docker tag version-v3 moazrefat/app:version-v3
docker push moazrefat/app:version-v3