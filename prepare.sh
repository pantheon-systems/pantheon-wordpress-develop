#!/bin/bash

###
# Authenticate with Terminus to perform site management operations.
#
# The $TERMINUS_TOKEN environment variable must be set with a valid machine token.
###
terminus auth login --machine-token=$TERMINUS_TOKEN

set -ex

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
cd ../

###
# Copy necessary accessory files to the environment
###
cp templates/wp-tests-config.php wordpress-develop/wp-tests-config.php
cp templates/test-runner.php wordpress-develop/test-runner.php
cp templates/wp-cli.local.yml wordpress-develop/wp-cli.local.yml
cp templates/composer.json wordpress-develop/composer.json

###
# Commit the necessary files to the environment
###
cd wordpress-develop
composer install
git add -f test-runner.php wp-cli.local.yml wp-tests-config.php vendor
git commit -m "Include requisite test runner dependencies"
git push upstream master:$PANTHEON_BRANCH
cd ../

###
# Switch environment to SFTP mode for running tests
###
terminus site set-connection-mode --site=$PANTHEON_SITE --env=$PANTHEON_BRANCH --mode=sftp
