#!/usr/bin/perl -w

##
## Put me in ~/.irssi/scripts, and then execute the following in irssi:
##
##       /load perl
##       /script load notify
##

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "0.01";
%IRSSI = (
    authors     => 'Luke Macken, Paul W. Frields',
    contact     => 'lewk@csh.rit.edu, stickster@gmail.com',
    name        => 'notify.pl',
    description => 'Use libnotify to alert user to hilighted messages',
    license     => 'GNU General Public License',
    url         => 'http://lewk.org/log/code/irssi-notify',
);
Irssi::settings_add_str('notify', 'notify_icon', 'gtk-dialog-info');
Irssi::settings_add_str('notify', 'notify_time', '5000');

#屏蔽bitlbee中某些特定nick的信息
#my @hidemsg = ("root", "pythoner", "dict");

sub sanitize {
  my ($text) = @_;
  $text =~ s/</&lt;/g;
  $text =~ s/>/&gt;/g;
  $text =~ s/'/&apos;/g;
  return $text;
}

sub notify {
    #当前活动窗口
    #my $active = 0;
    #my $active_id = `xprop -root _NET_ACTIVE_WINDOW`;
    #$active_id =~ s/.*\# //;
    #my $active_name = `xprop -id "$active_id" WM_NAME`;
    #$active_name =~ s/[^\"]*\"([^\"]*).*/$1/;
    #if ($active_name =~ m/screen: irssi/) {
        #$active = 1;
    #}
    #return if ($active eq 1);

    #OS detection
    my $os = `uname`;
    return if ($os = ~/Cygwin/);

    my ($server, $summary, $message) = @_;

    # Make the message entity-safe
    $summary = sanitize($summary);
    $message = sanitize($message);

    my $cmd = "EXEC - notify-send" .
	" -i " . Irssi::settings_get_str('notify_icon') .
	" -t " . Irssi::settings_get_str('notify_time') .
	" -- '" . $summary . "'" .
	" '" . $message . "'";

    $server->command($cmd);
}
 
sub print_text_notify {
    my ($dest, $text, $stripped) = @_;
    my $server = $dest->{server};
    return if (!$server || !($dest->{level} & MSGLEVEL_HILIGHT));
    
    my $sender = $stripped;
    $sender =~ s/[^\[]*\[([^\]]*).*/\1/;
    my $summary = $dest->{target} . "：" . $sender;
    $stripped =~ s/^\[.[^\]]+\].// ;
    
    #如果不在屏蔽列表中则提醒
    #if((!grep /$sender/, @hidemsg) or ($server->{tag} ne "bitlbee")){
        notify($server, $summary, $stripped);
    #}

}

sub message_private_notify {
    my ($server, $msg, $nick, $address) = @_;
    return if (!$server);
    
    #如果不在屏蔽列表中则提醒
    #if((!grep /$nick/, @hidemsg) or ($server->{tag} ne "bitlbee")){
        notify($server, "来自 ".$nick." 的私人消息", $msg);
    #}
}

sub dcc_request_notify {
    my ($dcc, $sendaddr) = @_;
    my $server = $dcc->{server};

    return if (!$dcc);
    notify($server, "DCC 请求：".$dcc->{type}, $dcc->{nick});
}

Irssi::signal_add('print text', 'print_text_notify');
Irssi::signal_add('message private', 'message_private_notify');
Irssi::signal_add('dcc request', 'dcc_request_notify');
