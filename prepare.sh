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
yes | terminus site wipe

###
# Get all necessary environment details.
###
PANTHEON_GIT_URL=$(terminus site connection-info --field=git_url)
PREPARE_DIR="/tmp/$TERMINUS_ENV-$TERMINUS_SITE"
BASH_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

###
# Clone the WordPress develop repo and push it to the new environment.
###
rm -rf $PREPARE_DIR
git clone git://develop.git.wordpress.org/ $PREPARE_DIR
cd $PREPARE_DIR
git remote add pantheonsite $PANTHEON_GIT_URL
git push -f pantheonsite master:$TERMINUS_ENV
cd $BASH_DIR

###
# Copy necessary accessory files to the environment.
###
cp $BASH_DIR/templates/wp-tests-config.php $PREPARE_DIR/wp-tests-config.php
cp $BASH_DIR/templates/test-runner.php $PREPARE_DIR/test-runner.php
cp $BASH_DIR/templates/wp-cli.local.yml $PREPARE_DIR/wp-cli.local.yml
cp $BASH_DIR/templates/composer.json $PREPARE_DIR/composer.json
wget https://downloads.wordpress.org/plugin/wordpress-importer.zip
unzip wordpress-importer.zip
rm wordpress-importer.zip
mv wordpress-importer $PREPARE_DIR/tests/phpunit/data/plugins/wordpress-importer

###
# Commit the necessary files to the environment.
###
cd $PREPARE_DIR
git log -1 --pretty=%B > latest-changeset.txt
composer install
git add -f latest-changeset.txt test-runner.php wp-cli.local.yml wp-tests-config.php vendor tests/phpunit/data/plugins/wordpress-importer
git config user.email "wordpress-develop@getpantheon.com"
git config user.name "Pantheon"
git commit -m "Include requisite test runner dependencies"
git push pantheonsite master:$TERMINUS_ENV
cd $BASH_DIR

###
# Switch environment to SFTP mode for running tests.
###
terminus site set-connection-mode --mode=sftp
