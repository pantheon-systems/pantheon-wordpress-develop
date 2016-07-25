#!/bin/bash

set -ex

if [ -z "$TERMINUS_SITE" ] || [ -z "$TERMINUS_ENV" ]; then
	echo "TERMINUS_SITE and TERMINUS_ENV environment variables must be set"
	exit 1
fi

###
# Get all necessary environment details.
###
PANTHEON_SSH_USER=$(terminus site connection-info --field=sftp_username)
PANTHEON_SSH_HOST=$(terminus site connection-info --field=sftp_host)

###
# Run the tests
###
ssh -p 2222 -o StrictHostKeyChecking=no $PANTHEON_SSH_USER@$PANTHEON_SSH_HOST wp phpunit
