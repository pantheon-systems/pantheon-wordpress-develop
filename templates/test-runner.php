<?php

/**
 * Run PHPUnit
 *
 * @when before_wp_load
 */
WP_CLI::add_command( 'phpunit', function(){
	$path = dirname( __FILE__ );
	passthru( $path . '/vendor/bin/phpunit', $exit_code );
	exit( $exit_code );
});
