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

/**
 * Report test results to Slack.
 *
 * ## OPTIONS
 *
 * <slack-webhook>
 * : Slack webhook URL.
 *
 * <slack-channel>
 * : Slack channel to report the results to.
 *
 * [<build-url>]
 * : URL for the build, to pass through to Slack.
 *
 * @when before_wp_load
 */
WP_CLI::add_command( 'phpunit-report', function( $args ){

	list( $webhook, $channel ) = $args;
	$build_url = isset( $args[2] ) ? $args[2] : '';

	$changeset_path = dirname( __FILE__ ) . '/latest-changeset.txt';
	$changeset_contents = file_get_contents( $changeset_path );
	if ( empty( $changeset_contents ) ) {
		WP_CLI::error( "Couldn't read latest changeset." );
	}
	$result_path = dirname( __FILE__ ) . '/tests/phpunit/build/logs/junit.xml';
	$result_xml = new SimpleXMLElement( file_get_contents( $result_path ) );
	if ( empty( $result_xml ) ) {
		WP_CLI::error( "Couldn't read junit.xml log." );
	}
	$test_count = (int) $result_xml->testsuite['tests'];
	$assertion_count = (int) $result_xml->testsuite['assertions'];
	$failure_count = (int) $result_xml->testsuite['failures'];
	$seconds = (int) $result_xml->testsuite['time'];
	$total_time = date( 'i \m\i\n s \s\e\c', $seconds );

	$rev_number = '(unknown changeset)';
	if ( preg_match( '#git-svn-id.+trunk@([\d]+)#', $changeset_contents, $matches ) ) {
		$rev_number = "(<https://core.trac.wordpress.org/changeset/{$matches[1]}|changeset r{$matches[1]}>)";
	}

	if ( $failure_count ) {
		$label = 'Failure';
		$verb = 'failed';
		$color = '#D00000';
	} else {
		$label = 'Success';
		$verb = 'passed';
		$color = '#36A64F';
	}

	if ( $build_url ) {
		$verb .= " (<{$build_url}|build>)";
	}

	$message = <<<EOT
{$label}: WordPress trunk {$rev_number} {$verb} on Pantheon in {$total_time} ({$test_count} tests, {$assertion_count} assertions, {$failure_count} failures).
EOT;

	$data = array(
		'username'    => 'pantheon-wordpress-develop-tests',
		'icon_emoji'  => ':wordpress:',
		'channel'     => $channel,
		'text'        => '',
		'attachments' => array(
			array(
				'text'    => $message,
				'color'   => $color,
			),
		),
	);

	$result = WP_CLI\Utils\http_request( 'POST', $webhook, json_encode( $data ), array( 'Content-Type' => 'application/javascript' ) );
	if ( 200 === $result->status_code ) {
		WP_CLI::success( 'Posted results to Slack' );
	} else {
		WP_CLI::error( "Couldn't post results to Slack (HTTP code {$result->status_code})" );
	}
});
