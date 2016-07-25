<?php

/**
 * Run PHPUnit
 *
 * @when before_wp_load
 */
WP_CLI::add_command( 'phpunit', function(){
	$path = dirname( __FILE__ );
	$contents = file_get_contents( $path . '/latest-changeset.txt' );
	echo PHP_EOL . '## LATEST CHANGESET' . PHP_EOL . PHP_EOL . $contents . PHP_EOL;
	passthru( $path . '/vendor/bin/phpunit', $exit_code );
	exit( $exit_code );
});
