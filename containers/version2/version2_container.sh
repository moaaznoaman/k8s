#!/bin/bash

docker build -t version-v2 .
docker tag version-v2 moazrefat/app:version-v2
docker push moazrefat/app:version-v2