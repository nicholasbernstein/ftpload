#!/bin/bash

/usr/bin/perl -MCPAN -e '
install Getopt::Long;
install Pod::Usage;
install Net::FTP;
install FileHandle;
install Time::Stopwatch;
'
