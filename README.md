# pantheon-wordpress-develop

Runs the [WordPress PHPUnit test suite](https://make.wordpress.org/core/handbook/testing/automated-testing/phpunit/) on [Pantheon](https://pantheon.io/) infrastructure to ensure Pantheon is fully compatible with WordPress.

[![CircleCI](https://circleci.com/gh/pantheon-systems/pantheon-wordpress-develop.svg?style=svg)](https://circleci.com/gh/pantheon-systems/pantheon-wordpress-develop)

## How It Works

The purpose of this repository is to verify that Pantheon's infrastructure is fully compatible with WordPress. Compatibility is verified by running the [WordPress PHPUnit test suite](https://make.wordpress.org/core/handbook/testing/automated-testing/phpunit/) on Pantheon on a regular, automated basis. The test running is handled end to end with CircleCI, and can easily be driven from your local environment too.

On a high level, here's how it works:

1. A new CircleCI job is [initiated through a cron job](https://circleci.com/docs/nightly-builds/), or manually.
2. The job environment defines three important environment variables:
 * `TERMINUS_TOKEN` - A [machine token](https://pantheon.io/docs/machine-tokens/) used for creating and deleting site environments on Pantheon. Because this token is meant to be kept secret, the value is set in the CircleCI admin, and not tracked in `circle.yml`.
 * `PANTHEON_SITE` - An existing Pantheon site to be used for running the test suite. This site must support [multidev](https://pantheon.io/features/multidev-cloud-environments), and the `TERMINUS_TOKEN` must be able to create and delete environments for this site.
 * `PANTHEON_BRANCH` - A unique name for the multidev branch to be created, to prevent collisions between jobs.
3. CircleCI installs [Terminus](https://pantheon.io/docs/terminus/), an interface for programmatically interacting with Pantheon.
4. The test suite runs in three steps:
 1. [`prepare.sh`](https://github.com/pantheon-systems/pantheon-wordpress-develop/blob/master/prepare.sh) - Prepares the Pantheon site environment to have the test suite run against it. Preparation includes:
    * Creating the site environment using Terminus.
    * Force pushing `git://develop.git.wordpress.org/` to the branch correlating with the site environment.
    * Committing the configuration files in [`templates/`](https://github.com/pantheon-systems/pantheon-wordpress-develop/tree/master/templates).
    * Committing a copy of PHPUnit
    * Now that the git operations have completed, changing the environment to SFTP mode.
 2. [`test.sh`](https://github.com/pantheon-systems/pantheon-wordpress-develop/blob/master/test.sh) - Runs the PHPUnit test suite through a WP-CLI command proxy.
 3. [`cleanup.sh`](https://github.com/pantheon-systems/pantheon-wordpress-develop/blob/master/cleanup.sh) - Cleans up after the test suite has completed. Cleanup includes:
    * Deleting the site environment using Terminus.

And that's it!

## Making Improvements

Need to improve this test runner in some way? You can clone the repository locally and run it against any Pantheon site.

**WARNING! WARNING!**

**PLEASE READ THE FOLLOWING VERY CAREFULLY.**

**BY FORCE PUSHING AGAINST `PANTHEON_BRANCH` AND ERASING THE DATABASE, THIS TEST RUNNER IRREVOCABLY DAMAGES YOUR PANTHEON SITE. USE ONLY WITH A SINGLE-USE, "THROWAWAY" SITE. DO NOT USE WITH ANY PANTHEON SITE THAT CANNOT BE DELETED.** 

With the warning out of the way and Terminus already installed on your machine, here's how you can use the test runner locally:

    git clone git@github.com:pantheon-systems/pantheon-wordpress-develop.git
    cd pantheon-wordpress-develop
    export PANTHEON_SITE=<disposable-site>
    export PANTHEON_BRANCH=<disposable-branch>
    export TERMINUS_TOKEN=<secret-token>
    ./prepare.sh
    ./test.sh
    ./cleanup.sh
    
Feel free to [open an issue](https://github.com/pantheon-systems/pantheon-wordpress-develop/issues) with any questions you may have.
