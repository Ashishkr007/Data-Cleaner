#!/usr/bin/perl
use warnings;
use strict;
use Path::Tiny; 
use Text::CSV;
use Time::Piece;
use File::Path qw( make_path );
use diagnostics;
use Try::Tiny;
 
my $date = localtime->strftime('%Y%m%d');
my $feed_date = $date;
 
if(exists($ARGV[3])){
  $feed_date = $ARGV[3];
}
 
# build source directory path ==>
my $source_feed_dir = $ARGV[0];
my $source_feed_dir_path = path($source_feed_dir);
# process i.e. current date 
my $source_feed_date_dir = $source_feed_dir_path->child($date); 
my $source_feed_date_dir2 = $source_feed_date_dir->child("data");
#feed date current date or could be argv supplied date 
my $source_feed_date_dir3 = $source_feed_date_dir2->child($feed_date); 
 
# build destination directory path as ==>
my $dest_feed_dir = $ARGV[1];
my $dest_feed_dir_path = path($dest_feed_dir);
my $dest_feed_date_dir_1 = $dest_feed_dir_path->child($date);  
my $dest_feed_date_dir = $dest_feed_date_dir_1->child($feed_date);
 
# build Logging directory path ==>
my $log_feed_dir = $ARGV[2];
my $log_feed_dir_path = path($log_feed_dir);
my $log_feed_date_dir = $log_feed_dir_path->child($date);
my $log_feed_date_file = $log_feed_date_dir->child(("Cleaning_Log_".localtime->strftime(("%Y_%m_%d_%H_%M_%S")).".log"));
 
 
my $current_time = localtime->strftime("%Y-%m-%d %H:%M:%S");
logger('LOG-1','STARTING CLEANING APPLICATION @ '.$current_time);
 
# check if source directory exists
if ( ! -e $source_feed_date_dir3) {
	logger('FAILURE','SOURCE DIRECTORY DOES NOT EXISTS: '."\n".$source_feed_date_dir3);
	exit 1;
}
 
    try {
        logger('LOG-2','OPENING SOURCE DIRECTORY :'."\n".$source_feed_date_dir3);
        opendir DIR, $source_feed_date_dir3;
 
    } catch {
        logger('FAILURE','FAILED TO OPEN SOURCE DIRECTORY : '."\n".$source_feed_date_dir3);
        exit 1;
    };
 
    my @file= my @files = grep { $_ ne '.' && $_ ne '..' } readdir DIR;
    closedir DIR;
 
foreach my $file (@file) {
    my $source_feed_date_file = $source_feed_date_dir3->child($file);
    my $dest_feed_date_file = $dest_feed_date_dir->child($file);
 
    try {
        if ( !-d $dest_feed_date_dir ) {
            make_path $dest_feed_date_dir;
        }
    } catch {
        logger('FAILURE','FAILED TO CREATE DESTINATION DIRECTORY : '."\n".$dest_feed_date_dir);
        exit 1;
    };
 
    my $csv = 'Text::CSV'->new({ binary => 1,
                                 eol => "\n",
                                                             sep_char => ",",
                                                             escape_char => undef ,
                                                             allow_loose_escapes => 1,
								 allow_loose_quotes => 1,
                                                             #always_quote => 1,
                                                             quote_char => "\"",
                                                             auto_diag => 1
                               })
    or die "CANNOT USE CSV: " . 'Text::CSV'->error_diag;
 
    logger('LOG-3','PROCESSING FILE :'."\n".$source_feed_date_file);
    try{
        open(my $CSV, '<:encoding(utf8)', $source_feed_date_file) ;
 
        open(my $fh, '>:encoding(utf8)', $dest_feed_date_file) ;
 
        while (my $row = $csv->getline($CSV)) {
            # replace CR and LF by space ==>
            s/\n|\r//g for @$row;
            $csv->print ($fh, $row);
        }
      } catch {
            logger('LOG-4','PROCESSING FAILED FOR FILE :'."\n".$source_feed_date_file);
            exit 1;
        };
    logger('LOG-4','PROCESSING ENDED FOR FILE :'."\n".$source_feed_date_file);
};
 
 
logger('LOG-5','CLEANED DATA FILE SAVED AT :'."\n".$dest_feed_date_dir);
 
logger('COMPLETE','DATA CLEANING COMPLETE @ '.localtime->strftime(("%Y-%m-%d %H:%M:%S")));
 
# sub-routine to log audit messages ==>
sub logger {
    my ($level, $msg) = @_;
 
	if ( !-d $log_feed_date_dir ) {
        make_path $log_feed_date_dir or die "FAILED TO CREATE LOGGING DIRECTORY : $log_feed_date_dir";
	}
 
    if (open my $out, '>>', $log_feed_date_file) {
        chomp $msg;
        print $out "\n\n"."*" x 80 . "\n";
        print $out "$level - $msg\n";
        print $out "*" x 80 . "\n";
    }
 
}
