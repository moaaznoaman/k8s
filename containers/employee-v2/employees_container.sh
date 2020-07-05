#!/bin/bash
docker build -t employee-v2 .
docker tag employee-v2 moazrefat/app:employee-v2
docker push moazrefat/app:employee-v2