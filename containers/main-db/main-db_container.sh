#!/bin/bash
docker build -t main-db .
docker tag main-db moazrefat/app:main-db
docker push moazrefat/app:main-db