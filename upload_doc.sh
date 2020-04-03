#!/bin/bash

# Upload the folder `site` via sftp to iai-webserv.kit.edu/morenet/www
ls
cd site
pwd
sftp -P 24 -b ../sftp.batch -oIdentityFile=~/.ssh/id_morenet_www morenet@iai-webserv.iai.kit.edu:morenet/www