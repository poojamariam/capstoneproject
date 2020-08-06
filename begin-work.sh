#!/bin/bash

# Fix permissions of persistent volumes
chmod 777 -R /tmp/host*

# Fix the docker socket permissions
SOCK_PERM=$(echo $(stat -c '%A' "/var/run/docker.sock"))
if [[ "$SOCK_PERM" != "srw-rw-rw-" ]]; then
        chmod 666 /var/run/docker.sock
fi

minikube start
sleep 5
minikube unpause -A
