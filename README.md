## Overview 
ftpload.pl is a simple threaded load tester for ftpdownloads. It requires a version of perl that
	supports threading, and several cpan modules, which can be installed via the install.sh
	script on unix.

## Usage:

	ftpload.pl -h <host> -u <username> -p <password> -f <file> -r <reps> -s <sets>
	ftpload.pl --host <host> --user <username> --password <password> --file <file> --reps <reps> --sets <sets>
	ftpload.pl --host=<host> --user=<username> --password=<password> --file=<file> --reps=<reps> --sets=<sets>\n
	The reps are the number of hits per set, so if you wanted to do 100 reps and 
	10 sets ftpload.pl -h localhost -u me -p password -r 100 -s 10 -f somefile.tgz
	username & password, if left blank will use anonymous & ftpload\@example.com respectively
  
---------------------------------------------
ftpload.pl requires several cpan modules. You are more than welcome to get them yourself, but
I've included a script called install.pl that uses perl's -MCPAN to pull them down. You will need to run this as
root, and will need to go though the cpan setup if it's not currently configured. 
