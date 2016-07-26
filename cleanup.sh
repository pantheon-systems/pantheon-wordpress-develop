#!/bin/bash

set -ex

if [ -z "$TERMINUS_SITE" ] || [ -z "$TERMINUS_ENV" ]; then
	echo "TERMINUS_SITE and TERMINUS_ENV environment variables must be set"
	exit 1
fi

###
# Report the results to Slack (privately)
###
set +x
if [ ! -z "$SLACK_WEBHOOK" ] && [ ! -z "$SLACK_CHANNEL" ]; then
	PANTHEON_SSH_USER=$(terminus site connection-info --field=sftp_username)
	PANTHEON_SSH_HOST=$(terminus site connection-info --field=sftp_host)
	SLACK_CHANNEL=${SLACK_CHANNEL/#/\\#}
	ssh -p 2222 -o StrictHostKeyChecking=no $PANTHEON_SSH_USER@$PANTHEON_SSH_HOST wp phpunit-report $SLACK_WEBHOOK $SLACK_CHANNEL $CIRCLE_BUILD_URL
fi
set -x

###
# Delete the environment used for this test run.
###
yes | terminus site delete-env --remove-branch
