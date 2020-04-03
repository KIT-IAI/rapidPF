#!/bin/bash

# This file adds the private key MKDOCS_KEY ad the host SSH_KNOWN_HOST to the list of known hosts
ls /
cp /matdoc/* .
mkdir -p ~/.ssh
echo "$MKDOCS_KEY" > ~/.ssh/id_morenet_www
chmod 400 ~/.ssh/id_morenet_www
eval $(ssh-agent -s)
echo "$SSH_KNOWN_HOSTS" > ~/.ssh/known_hosts
chmod 644 ~/.ssh/known_hosts