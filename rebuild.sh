#!/bin/bash
set -e
sudo docker run --rm -ti -v /home/vlad/code/crystal-test/:/code/ -w /code/ crystallang/crystal:latest-alpine shards build --static --no-debug --release
