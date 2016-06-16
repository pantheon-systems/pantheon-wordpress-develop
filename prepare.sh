#!/bin/bash

###
# Authenticate with Terminus to perform site management operations.
#
# The $TERMINUS_TOKEN environment variable must be set with a valid machine token.
###
terminus auth login --machine-token=$TERMINUS_TOKEN

###
# Create a new environment for this particular test run.
###
terminus site create-env --to-env=$PANTHEON_BRANCH --from-env=dev --site=$PANTHEON_SITE

###
# Get all necessary environment details.
###
PANTHEON_GIT_URL=$(terminus site connection-info --field=git_url --site=$PANTHEON_SITE --env=$PANTHEON_BRANCH)

###
# Clone the WordPress develop repo and push it to the new environment.
###
git clone git://develop.git.wordpress.org/ wordpress-develop
cd wordpress-develop
git remote add upstream $PANTHEON_GIT_URL
git push -f upstream master:$PANTHEON_BRANCH
