#!/usr/bin/env bash
instance=$1
eval `docker-machine env $instance`
docker ps

