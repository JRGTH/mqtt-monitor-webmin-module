#!/usr/local/bin/perl
# index.cgi

require './mqttmonitor-lib.pl';

# Check if mosquitto exists.
if (!&has_command($config{'cmd_path'})) {
	&ui_print_header(undef, $text{'index_title'}, "", "intro", 1, 1);
	print &text('index_errmqtt', "<tt>$config{'cmd_path'}</tt>",
		"$gconfig{'webprefix'}/config.cgi?$module_name"),"<p>\n";
	&ui_print_footer("/", $text{"index"});
	exit;
	}

# Get mosquitto version.
my $version = &get_mqtt_version();
if (!$version == "blank") {
	# Display version.
	&write_file("$module_config_directory/version", {""},$version);
	&ui_print_header(undef, $text{'index_title'}, "", "intro", 1, 1, 0,
		&help_search_link("mosquitto_sub", "man", "doc", "google"), undef, undef,
		&text('index_version', "$text{'index_modver'} $version"));
	}
else {
	# Don't display version.
	&ui_print_header(undef, $text{'index_title'}, "", "intro", 1, 1, 0,
		&help_search_link("mosquitto_sub", "man", "doc", "google"), undef, undef,
		&text('index_version', ""));
}

# Start tabs.
@tabs = ();
push(@tabs, [ "info", $text{'index_mqtttab'}, "index.cgi?mode=info" ]);
#push(@tabs, [ "res", $text{'index_mqttres'}, "index.cgi?mode=res" ]);
if ($config{'show_conf'}) {
	push(@tabs, [ "conf", $text{'index_edit'}, "index.cgi?mode=conf" ]);
	}
if ($config{'show_advanced'}) {
	push(@tabs, [ "advanced", $text{'index_advanced'}, "index.cgi?mode=advanced" ]);
	}
print &ui_tabs_start(\@tabs, "mode", $in{'mode'} || $tabs[0]->[0], 1);

# Start MQTT list tab.
print &ui_tabs_start_tab("mode", "info");
&ui_mqtt_list();
print &ui_tabs_end_tab("mode", "info");

# Start MQTT config tab.
if ($config{'show_conf'}) {
	print &ui_tabs_start_tab("mode", "conf");
	&ui_mqtt_conf();
	print &ui_tabs_end_tab("mode", "conf");
	}

# Start MQTT advanced tab.
if ($config{'show_advanced'}) {
	print &ui_tabs_start_tab("mode", "advanced");
	&ui_mqtt_advanced();
	print &ui_tabs_end_tab("mode", "advanced");
	}

# End tabs.
print &ui_tabs_end(1);

if ($config{'show_cmd'}) {
	# Check if mosquitto is running.
	$pid = &get_mqtt_pid();
	print &ui_hr();
	print &ui_buttons_start();
	if ($pid) {
		# Running .. offer to restart and stop.
		print &ui_buttons_row("stop.cgi", $text{'index_stop'}, $text{'index_stopmsg'});
		print &ui_buttons_row("restart.cgi", $text{'index_restart'}, $text{'index_restartmsg'});
		}
	else {
		# Not running .. offer to start.
		print &ui_buttons_row("start.cgi", $text{'index_start'}, $text{'index_startmsg'});
		}
	print &ui_buttons_end();
}

print &ui_columns_row(["$text{'index_refreshinfo'}"]);
print &ui_columns_end();

&ui_print_footer("/", $text{'index'});
