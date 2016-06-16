#!/bin/bash

###
# Delete the environment used for this test run.
###
yes | terminus site delete-env --env=$PANTHEON_BRANCH --site=$PANTHEON_SITE --remove-branch
