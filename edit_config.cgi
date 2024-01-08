#!/usr/local/bin/perl
# edit_config.cgi
# Show a page for manually editing an mosquitto_sub config file

require './mqttmonitor-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'index_title'}, "");

@files = ( "$config{'cmd_confpath'}", "$config{'cmd_confpath_server'}" );
$in{'file'} ||= $files[0];
&indexof($in{'file'}, @files) >= 0 || &error($text{'manual_efile'});
print &ui_form_start("edit_config.cgi");
print "<b>$text{'manual_file'}</b>\n";
print &ui_select("file", $in{'file'},
		 [ map { [ $_ ] } @files ]),"\n";
print &ui_submit($text{'manual_ok'});
print &ui_form_end();

# Show the file contents
print &ui_form_start("save_config.cgi", "form-data");
print &ui_hidden("file", $in{'file'}),"\n";
$data = &read_file_contents($in{'file'});
print &ui_textarea("data", $data, 20, 80),"\n";
print "<b>$text{'manual_editnote'}<b>";
print &ui_form_end([ [ "save", $text{'save'} ] ]);

&ui_print_footer("", $text{'index_return'});
