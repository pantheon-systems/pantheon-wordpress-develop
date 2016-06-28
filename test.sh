#!/bin/bash

set -ex

###
# Get all necessary environment details.
###
PANTHEON_SSH_USER=$(terminus site connection-info --field=sftp_username)
PANTHEON_SSH_HOST=$(terminus site connection-info --field=sftp_host)

###
# Run the tests
###
ssh -p 2222 -o StrictHostKeyChecking=no $PANTHEON_SSH_USER@$PANTHEON_SSH_HOST wp phpunit
