#!/usr/local/bin/perl
# mqttmonitor-lib.pl

BEGIN { push(@INC, ".."); };
use WebminCore;
&init_config();

#my $mqtt_stat_props="$config{'mqtt_monitor'}";
#my $mqtt_cmd_props="$config{'mqtt_command'}";

# Get mosquitto version
sub get_mqtt_version
{
my $getversion = "$config{'cmd_path'} --version | awk '{print \$1,\$3}'";
my $version = &backquote_command("$getversion");
}

# Get pid file
# Returns the mosquitto PID file.
sub get_pid_file
{
$pidfile = $config{'pid_file'};
return $pidfile;
}

# Get mosquitto pid
# Returns the PID of the running mosquitto process.
sub get_mqtt_pid
{
local $file = &get_pid_file();
if ($file) {
	return &check_pid_file($file);
	}
else {
	local ($rv) = &find_byname("mosquitto");
	return $rv;
	}
}

# Kill mosquitto related processes.
sub kill_mqtt_procs
{
my $killmqttprocs = &backquote_command("pkill -f mosquitto");
}

sub list_mqtt
{
my %mqtt=();
my $list=&backquote_command("timeout $config{'cmd_timeout'} $config{'cmd_path'} $config{'cmd_args_prefix'} -h $config{'cmd_ipaddr'} -p $config{'cmd_ipport'} -v $config{'mqtt_topics'} $config{'cmd_args_postfix'}");
open my $fh, "<", \$list;
while (my $line =<$fh>)
{
	chomp ($line);
	my @props = split(" ", $line, 2);
		$ct = 1;
		foreach $prop (split(",", "VALUE")) {
			$mqtt{$props[0]}{$prop} = $props[$ct];
			$ct++;
		}

}
return %mqtt;
}

sub list_mqtt_cmd
{
my %mqtt=();
my $list=&backquote_command("");

open my $fh, "<", \$list;
while (my $line =<$fh>)
{
	chomp ($line);
	my @props = split(" ", $line, 2);
		$ct = 1;
		foreach $prop (split(",", "DESCRIPTION")) {
			$mqtt{$props[0]}{$prop} = $props[$ct];
			$ct++;
		}

}
return %mqtt;
}

# Mosquitto summary list.
sub ui_mqtt_list
{
my %mqtt = list_mqtt($mqtt);
@props = split(/,/, "VALUE");
print &ui_columns_start([ "PROPERTY", @props ]);
my $num = 0;
foreach $key (sort(keys %mqtt))
{
	@vals = ();
	foreach $prop (@props) { push (@vals, $mqtt{$key}{$prop}); }
	# Disable start, stop and restart buttons.
	print &ui_columns_row([ "<a href='index.cgi?mqtt=$key'>$key</a>", @vals ]);
	$num ++;
}
print &ui_columns_end();
}

# Mosquitto available command list.
# This is for devel testing only and not yet implemented.
sub ui_mqtt_advanced_test
{
my %mqtt = list_mqtt_cmd($mqtt);
@props = split(/,/, "DESCRIPTION");
print &ui_columns_start([ "COMMAND", @props ]);
my $num = 0;
foreach $key (sort(keys %mqtt))
{
	@vals = ();
	foreach $prop (@props) { push (@vals, $mqtt{$key}{$prop}); }
	# Execute mosquitto command.
	if ($config{'allow_cmdexec'}) {
		print &ui_columns_row([ "<a href='exec.cgi?mqtt=$key'>$key</a>", @vals ]);
		}
	else {
		print &ui_columns_row([ "<a href='index.cgi?mqtt=$key'>$key</a>", @vals ]);
	}
	$num ++;
}
print &ui_columns_end();
}

sub ui_mqtt_conf
{
# Display icons for options.
if ($config{'show_conf'}) {
	push(@links, "edit_config.cgi");
	push(@titles, $text{'manual_mqttedit'});
	push(@icons, "images/manual.gif");
	}
&icons_table(\@links, \@titles, \@icons, 4);
}

# Restart mosquitto, and returns an error message on failure or
# undef on success.
sub restart_mosquito_serv
{
if ($config{'restart_cmd'}) {
	local $out = &backquote_command("$config{'restart_cmd'} 2>&1 </dev/null");
	return "<pre>$out</pre>" if ($?);
	}
else {
	# Just kill mosquitto related processes and start mosquitto.
	&kill_mqtt_procs;
	if ($config{'start_cmd'}) {
	$out = &backquote_logged("$config{'start_cmd'} 2>&1 </dev/null");
	if ($?) { return "<pre>$out</pre>"; }
		}
	}
return undef;
}

# Always use stop command whenever possible, otherwise
# try to kill the mosquitto service, returns an error message on failure or
# undef on success.
sub stop_mosquito_serv
{
if ($config{'stop_cmd'}) {
	local $out = &backquote_command("$config{'stop_cmd'} 2>&1 </dev/null");
	return "<pre>$out</pre>" if ($?);
	}
else {
	# Just kill mosquitto related processes.
	&kill_mqtt_procs;
	}
return undef;
}

# Attempts to start mosquitto, returning undef on success or an error
# message on failure.
sub start_mosquito_serv
{
# Remove PID file if invalid.
if (-f $config{'pid_file'} && !&check_pid_file($config{'pid_file'})) {
	&unlink_file($config{'pid_file'});
	}
if ($config{'start_cmd'}) {
	$out = &backquote_logged("$config{'start_cmd'} 2>&1 </dev/null");
	if ($?) { return "<pre>$out</pre>"; }
	}
else {
	$out = &backquote_logged("$config{'pid_file'} 2>&1 </dev/null");
	if ($?) { return "<pre>$out</pre>"; }
	}
return undef;
}

# Attempts to execute mosquitto command, returning undef on success or an error message.
# This is for devel testing only and not yet implemented.
sub exec_mqtt_cmd_test
{
if ($config{'show_advanced'}) {
	if ($config{'allow_cmdexec'}) {
		if (($config{'mqtt_username'}) && ($config{'mqtt_password'}))  {
			my $devicename = $config{'dev_name'};
			my $username = $config{'mqtt_username'};
			my $userpass = $config{'mqtt_password'};
			my $mqttcmd = $in{'mosquitto'};

			#local $out = &backquote_logged("command_args_here 2>&1 </dev/null");

			if ($?) {
				return "<pre>$out</pre>";
			} else {
				&ui_print_header(undef, $text{'index_title'}, "");
				@result = $out;
				if (!$result[0]) {
					print "$text{'exec_ok'} [$mqttcmd]<br/>";
				} else {
					print "<b>$text{'exec_output'} [$mqttcmd]<br><br></b>".$result[0]."<br/>";
					foreach $key (@result[1..@result]) {
						print $key."<br/>";
						}
				}
				&ui_print_footer("", $text{'index_return'});
			}
		}
	}
}
return undef;
}

1;
