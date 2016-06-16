#!/bin/bash

set -ex

###
# Get all necessary environment details.
###
PANTHEON_SSH_USER=$(terminus site connection-info --field=sftp_username --site=$PANTHEON_SITE --env=$PANTHEON_BRANCH)
PANTHEON_SSH_HOST=$(terminus site connection-info --field=sftp_host --site=$PANTHEON_SITE --env=$PANTHEON_BRANCH)

###
# Run the tests
###
ssh -p 2222 -o StrictHostKeyChecking=no $PANTHEON_SSH_USER@$PANTHEON_SSH_HOST wp phpunit
