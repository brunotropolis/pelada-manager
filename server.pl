#!/usr/bin/perl
use strict; use warnings;
use HTTP::Daemon;
use HTTP::Status;
use File::Basename;

my $port = $ENV{PORT} || 3335;
my $root = dirname(__FILE__);

my $d = HTTP::Daemon->new(LocalPort => $port, ReuseAddr => 1)
  or die "Cannot start server: $!";

print "Server running at http://localhost:$port\n";
$| = 1;

while (my $c = $d->accept) {
  while (my $r = $c->get_request) {
    my $path = $r->uri->path;
    $path = '/index.html' if $path eq '/';
    $path =~ s|[^a-zA-Z0-9._/-]||g;
    my $file = "$root$path";
    if (-f $file) {
      $c->send_file_response($file);
    } else {
      $c->send_error(RC_NOT_FOUND);
    }
  }
  $c->close;
}
