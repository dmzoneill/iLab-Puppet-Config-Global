#!/bin/bash

# set cron update script
echo "*/10 * * * * root /etc/puppet/scripts/gitpull.sh > /var/log/gitpull 2>&1" > /etc/cron.d/puppetgitpull

