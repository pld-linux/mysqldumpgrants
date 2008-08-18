#!/usr/bin/perl

################################################################################
#
#  mysqldumpgrants
#
#  Copyright (C) 2004, 2006 MeteoNews GmbH, b.vontobel@meteonews.ch
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  http://www.gnu.org/licenses/gpl.txt
#
################################################################################

=head1 NAME

mysqldumpgrants - dumps grants from a MySQL database as valid SQL

=head1 SYNOPSIS

mysqldumpgrants [options] [user_pattern[@host_pattern]]

=head1 DESCRIPTION

mysqldumpgrants dumps the grants of a MySQL database as valid SQL
commands.

mysqldumpgrants reads the user, password, host and port settings
from your .my.cnf file by default. These settings can be overriden
with the options provided on the command line.

The optional argument user_pattern[@host_pattern] controls which
accounts should be dumped (defaults to all). You can use the
usual MySQL wildcards _ and %.

You can redirect the output of mysqldumpgrants to a file to backup
your user accounts or to easily edit them in a text editor or you
can pipe it to the mysql command line client to copy them
directly to another server, like so:

  mysqldumpgrants -h mysql1 a% | mysql -h mysql2

This would copy all the user accounts starting with the letter
'a' from host mysql1 to mysql2 (given both servers use the same
credentials for login and those are stored in a .my.cnf file).

=head1 OPTIONS

=over

=item -u, --user=#

user for database login

=item -p, --password

ask for password (you can't provide a password on the command line for
security reasons, use a .my.cnf file instead)

=item -h, --host=#

hostname of database server to connect to

=item -P, --port=#

port to use when connecting to database server

=item -d, --drop-user

adds a DROP USER command for every dumped user just before the GRANT
commands

=item -?, --help

display this help page

=back

=head1 AUTHOR

Beat Vontobel, MeteoNews GmbH (b.vontobel@meteonews.ch)

=head1 HISTORY

=over

=item 2004-07-14

first version

=item 2005-01-11

added some error handling, now reads .my.cnf defaults that can be
overriden by command line options, changed comment characters in SQL output
from # to --

=item 2006-04-16

added -? and --help options and this documentation, password is no longer
echoed (if Term::ReadKey is available)

=back

=cut

use strict;
use warnings;

use DBI;
use Getopt::Long;
use Pod::Usage;

my $host = "";
my $port = "";
my $user = undef;
my $pass = undef;

my $help;
my $drop;

my $user_pattern = '%';
my $host_pattern = '%';

my $exit = 0;

GetOptions('host|h=s'     => \$host,
           'port|P=i'     => \$port,
           'user|u=s'     => \$user,
           'password|p'   => \$pass,
           'drop-user|d'  => \$drop,
           'help|?'       => \$help)
    or pod2usage(2);

pod2usage(1) if $help;

if(scalar(@ARGV) == 1) {
    ($user_pattern, $host_pattern) = split('@', $ARGV[0]);
    $host_pattern = defined($host_pattern) ? $host_pattern : '%';
} elsif(scalar(@ARGV) > 1) {
    pod2usage(2);
}

if($pass) {
    print STDERR "Enter password: ";
    eval {
        require Term::ReadKey;
        import  Term::ReadKey qw(ReadMode ReadLine);
    };
    if($@ eq "") {
        ReadMode('noecho');
        $pass = ReadLine(0);
        ReadMode('restore');
        print STDERR "\n";
    } else {
        $| = 1;
        $pass = <STDIN>;
    }
    chomp $pass;
}

my $db = DBI->connect("DBI:mysql:mysql_read_default_group=mysql;host=$host;port=$port",
                      $user,
                      $pass,
                      { PrintError => 0 });
$db or die($DBI::errstr."\n");

if(my $info = $db->selectrow_arrayref("SELECT NOW(), VERSION()")) {
    print "-- Grants for pattern $user_pattern\@$host_pattern extracted by $0\n";
    print "-- ${$info}[0] (MySQL ${$info}[1])\n\n";
} else {
    die($db->errstr."\n");
}

my $userQuery  = $db->prepare("SELECT user, host FROM mysql.user ".
                      "WHERE user LIKE ? AND host LIKE ? ORDER BY user, host");
my $grantQuery = $db->prepare("SHOW GRANTS FOR ?@?");

$userQuery->execute($user_pattern, $host_pattern)
    or die($db->errstr."\n");

while(my $ud = $userQuery->fetchrow_arrayref()) {
    print "-- ${$ud}[0]\@${$ud}[1]\n";
    print "DROP USER '${$ud}[0]'\@'${$ud}[1]';\n" if $drop;
    if($grantQuery->execute(${$ud}[0], ${$ud}[1])) {
        while(my $grant = $grantQuery->fetchrow_arrayref) {
            print ${$grant}[0];
            print ";\n";
        }
    } else {
        print "-- Error: Couldn't execute SHOW GRANTS (".$db->errstr.")\n";
        $exit = 1;
    }
    print "\n";
}

$db->disconnect;

exit $exit;

__END__
