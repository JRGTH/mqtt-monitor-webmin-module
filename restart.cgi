#!/usr/local/bin/perl
# restart.cgi
# Restart the mosquitto_sub daemon

require './mqttmonitor-lib.pl';
&ReadParse();
&error_setup($text{'restart_err'});
$err = &restart_mosquitto_serv();
&error($err) if ($err);
&webmin_log("restart");
&redirect("");
