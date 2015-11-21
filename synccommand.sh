#!/bin/bash

rsync -e="ssh -q" \
    --info=stats2 \
    --exclude-from=sync.excludes \
    --archive \
    --delete \
    --verbose \
    --no-perms --no-owner --no-group \
    . \
    docker@192.168.10.10:/projects/OpenCPU
