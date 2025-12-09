#!/bin/bash
cat /etc/letsencrypt/live/DOMAIN/privkey.pem /etc/letsencrypt/live/DOMAIN/fullchain.pem | tee PATH/docker/haproxy/config/ssl/DOMAIN.pem
docker-compose -f PATH/docker/haproxy/docker-compose.yml down
docker-compose -f PATH/docker/haproxy/docker-compose.yml up -d