#!/usr/local/bin/perl
# start.cgi
# Start the mosquitto_sub daemon

require './mqttmonitor-lib.pl';
&ReadParse();
&error_setup($text{'start_err'});
$err = &start_mosquito_serv();
&error($err) if ($err);
&webmin_log("start");
&redirect("");
