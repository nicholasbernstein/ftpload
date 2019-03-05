#!/usr/bin/perl -w
tie my $program_timer, 'Time::Stopwatch';
#Version
$major="0"; $minor="2";

=pod
ftpload.pl:
ftpload.pl is a simple threaded command line ftp load/stress tester written in perl.

Author: Nick Bernstein
Homepage: http://nicholasbernstein.com/scripts.php

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

=cut

# CPAN Modules -----------

use threads; 
use Net::FTP;
use FileHandle;
use Time::Stopwatch;
use Getopt::Long;
use Pod::Usage;

# Functions ---------------

sub show_argv(){
	foreach  my $var ( @ARGV ) {
        	print "\n$var ";
	}
}

sub myopen {
=pod
	example of use: my $f = myopen(">/dev/null");
=cut
	open my $fh, "@_"
		or die "Can't open '@_': $!";
	return $fh;
}

sub open_new_ftp {
	tie my $timer, 'Time::Stopwatch';
	my $host = $_[0];
	my $uname=$_[1];
	my $pass=$_[2];
	my $file=$_[3];
	my $name=$_[4];
	my $start = time();
	my $f = myopen(">/dev/null");

	my $ftp = Net::FTP->new("$host", Debug => 0)
      		or die "Cannot connect to $host $@";

    	$ftp->login("$uname","$pass")
      		or die "user $uname cannot login ", $ftp->message;

    	$ftp->get("$file",$f)
      		or die "get failed ", $ftp->message;

    	$ftp->quit;
	my $ms=($timer*1000);  		# convert seconds -> milliseconds 
	print "thread $name:\t";
	printf("%6.1f",$ms); 
	print "\n";
	return $ms;
	if (defined($quiet)) { print "QUIET!" } ;
}

# Variables -------

# Defaults
my $user="anonymous";
my $password="ftpload\@example.com";
my $file="";
my $reps="1";
my $sets="1";

GetOptions(
	"host|h=s" 	=> \$host, 
	"user|u=s" 	=> \$uname,
	"password|p=s"	=> \$pass,
	"file|f=s"	=> \$file,
	"reps|r=i"	=> \$reps,
	"sets|s=i"	=> \$sets,
	"help"		=> \$help,
	"version|v"	=> \$showversion,
	"quiet"		=> \$quiet,

) or die "Can't get variable";

# Main --------------------
if ( ! defined($host) or  ! defined($file) ) { $help="true"; } ;

if ( defined($help) ) {
	$help_message="\n ftpload.pl \n
	ftpload.pl is a simple threaded load tester for ftpdownloads. It requires a version of perl that
	supports threading, and several cpan modules, which can be installed via the install.sh
	script on unix.

	Usage:\n
	ftpload.pl -h <host> -u <username> -p <password> -f <file> -r <reps> -s <sets>
	ftpload.pl --host <host> --user <username> --password <password> --file <file> --reps <reps> --sets <sets>
	ftpload.pl --host=<host> --user=<username> --password=<password> --file=<file> --reps=<reps> --sets=<sets>\n
	The reps are the number of hits per set, so if you wanted to do 100 reps and 
	10 sets ftpload.pl -h localhost -u me -p password -r 100 -s 10 -f somefile.tgz
	username & password, if left blank will use anonymous & ftpload\@example.com respectively.\n\n";
	print $help_message ;
	exit(1);
}

if ( defined($showversion) ){
	print "ftpload.pl $major.$minor";
	exit(0);
}
print "Host: $host -> $file \n"; 
for ($run=1; $run<=$sets; $run++){
	print "----------\nSet $run:\n----------\n" unless (defined($quiet));
	for ($i=1; $i<=$reps; $i++){
		$thr[$i] = threads->new(\&open_new_ftp, "$host", "$uname", "$pass", "$file", "$i");
		$thr[$i]->detach;
	}
}
print "\nTotal run time:\t" ;
printf("%6.3f", $program_timer);
print " seconds\n";
