#!/usr/local/bin/perl
# exec.cgi
# Execute mosquitto_sub command

require './mqttmonitor-lib.pl';
&ReadParse();
&error_setup("$text{'exec_err'} [$in{'mosquito_sub'}]");
$err = &exec_mosquitto_sub();
&error($err) if ($err);
&webmin_log("exec");
&redirect("");
