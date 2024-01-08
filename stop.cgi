#!/usr/local/bin/perl
# stop.cgi
# Stop the mosquitto_sub daemon

require './mqttmonitor-lib.pl';
&ReadParse();
&error_setup($text{'stop_err'});
$err = &stop_mosquito_serv();
&error($err) if ($err);
&webmin_log("stop");
&redirect("");
