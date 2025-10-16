#!/bin/bash

if [ -f server.env ]; then
    source server.env
else
    exit 1
fi

ssh -t ${TARGET_HOST} "sudo timedatectl set-timezone Asia/Seoul" > /dev/null 2>&1

ssh ${TARGET_HOST} "timedatectl"