#!/bin/bash

set -ex

if [ -z "$TERMINUS_SITE" ] || [ -z "$TERMINUS_ENV" ]; then
	echo "TERMINUS_SITE and TERMINUS_ENV environment variables must be set"
	exit 1
fi

###
# Create a new environment for this particular test run.
###
terminus site create-env --to-env=$TERMINUS_ENV --from-env=dev

###
# Get all necessary environment details.
###
PANTHEON_GIT_URL=$(terminus site connection-info --field=git_url)

###
# Clone the WordPress develop repo and push it to the new environment.
###
git clone git://develop.git.wordpress.org/ wordpress-develop
cd wordpress-develop
git remote add pantheonsite $PANTHEON_GIT_URL
git push -f pantheonsite master:$TERMINUS_ENV
cd ../

###
# Copy necessary accessory files to the environment.
###
cp templates/wp-tests-config.php wordpress-develop/wp-tests-config.php
cp templates/test-runner.php wordpress-develop/test-runner.php
cp templates/wp-cli.local.yml wordpress-develop/wp-cli.local.yml
cp templates/composer.json wordpress-develop/composer.json

###
# Commit the necessary files to the environment.
###
cd wordpress-develop
composer install
git add -f test-runner.php wp-cli.local.yml wp-tests-config.php vendor
git config user.email "wordpress-develop@getpantheon.com"
git config user.name "Pantheon"
git commit -m "Include requisite test runner dependencies"
git push pantheonsite master:$TERMINUS_ENV
cd ../

###
# Switch environment to SFTP mode for running tests.
###
terminus site set-connection-mode --mode=sftp
