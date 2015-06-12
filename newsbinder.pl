#!/usr/bin/perl

# NewsBinder v1.0
# Written By Kevin Fowlks
# July 20th 2001
# Released Under GPL License

# July 30th,2001
# Changes Made By : Soren Andersen <soren(at)wonderstorm.com>
# Added: `File::Spec' now used for addressing output directorys added.
# Added:  Sub to get the true output filename minus the directoy path used by some news agents.
# Added:  Support for Term::ANSIColor to get highlighted output.
# Added:  Sub to truncate output to fit screen and not wrap.   

# July 30th,2001
# Changes Made By : Kevin Fowlks <kamka(at)760mp.com>
# Added: -nd or -nodisplay switch which only displays the essential information on binary files.

# Aug 3rd, 2001
# Changes Made By : Soren Andersen <soren(at)wonderstorm.com>
# Added: News Server Authentication scheme (see readme.txt for details) 
# Change: Made some of the code More perl-ish :) 

# Aug 4th,2001
# Changes Made By : Kevin Fowlks <kamka(at)760mp.com>
# Fixed : Total number of binary files was broken.
# Fixed : Substring search (This should now work the way it was intended :) )
# Added: Search Expression is now shown with the Binary stats.

sub BinaryC($$$$$);
sub round($);
sub artgraber($$$);
sub getgrouplist($$$);

use News::NNTPClient;
use Convert::UU 'uudecode';
use File::Spec::Functions qw(splitpath catfile);
use Term::ANSIColor;


#use diagnostics;

# Normal Var's
my $numbins_total = 0;
my $num_complete = 0;
my $gnumbins_total = 0;
my $gnumart_total = 0;
my $gnum_complete = 0;
my $ver = "v1.06";

# Arrays
my @duplist=();

# Hash's
my %art_partslist = ();
my %art_mult = ();
my %art_multnum = ();
my %art_ID = ();
my %art_ServerID = ();
my %art_sets = ();
my %art_setcolor = ();
my %art_size = ();


my $nodownload = "no";
my $outdir = "";
my $news_servers = "news.ini";
my $port;
my $regex=".";
my $setkey;
my $nodisplay="no";

# Get Commmand Line Arg #################################################

	sub usage()
	{ print "NewsBinder $ver  Created By: Kevin Fowlks\n";
  	  print "usage: $0 [-v] [-h] [-o] [-l] <-g> regexp \n";
	  print "\t -nd or --nodisplay (Only displays the Important Info When Downloading a File)\n";
	  print "\t -v or --version (Display Version)\n";
	  print	"\t -h or --help    (Displays This Info Here)\n";
	  print	"\t -o or --output  (Output Directory)\n";
	  print "\t -l or --list    (Displays a lists of all the articles that you might want to download)\n";
	  print "\t -g or --group   *Required (Selects Group That You Want To Download From)\n";
	  print	"\t  substring default is everything (Grabs all articles that match)\n";
 	  exit(0);
	}

	sub version()
	{
	  print "NewsBinder Version: $ver July 20th 2001 \n";
	  exit(0);
	}

	if (@ARGV == 0) {
	# No arguments means usage()
	    usage();
	}

	while ($_ = shift(@ARGV)) {
	if (/-h/ || /--help/) {
		usage();
		next;
	}
	if (/-v/ || /--version/) {
		version();
		next;
	}
	if (/-o/ || /--output/) {
		$outdir = shift(@ARGV);
		next;
	}
	elsif (/-g/ || /--group/) {
		$grp = shift(@ARGV);
		next;
	}
	elsif (/-l/ || /--list/) {
		$nodownload = "yes"; #shift(@ARGV);
		next;
	}
	elsif (/-nd/ || /--nodisplay/) {
		$nodisplay = "yes"; #shift(@ARGV);
		next;
	}
	 else {
		$regex = $_;
		next;
		}
	}

	if (!$grp) {
	    usage();
	    exit;
	}




# Start of News Gather
# Loop through all news servers found in news.ini then proceeds to BIND servers articles together
# Main Program Here --> begin


print "Starting NewsBinder $ver\n";

my $temp_file = "temp_$$.tmp";
my ($nhost,$auth_data);
open (FILEHANDLE_READ, "<news.ini")
     or die "Cannot Open File news.ini For Input\n";
 $|=1; # Flush Print Outputs
 while (<FILEHANDLE_READ>) {
   ($nhost,$auth_data) = split /\s+/,$_;
   if ($nhost ne '')  {
      print "Reading Host:  $nhost\n";
      artgraber($grp,$nhost,$auth_data);
   }
}
 $nhost = '';
 close FILEHANDLE_READ;

# End of News Gather
# Done This is nothing more then a tally of all the binaries files we have

	my $key;
	my $ipart;
	my @line=();
 	my $skipfile;
	my $fo;

 	foreach $key (%art_mult)
	{

	      # ($key =~ m/.* $regex .*/i)

	      if (($art_mult{$key} == $art_multnum{$key}) && ($key =~ m/$regex/i ) &&
		 ($art_partslist{$key}))
                    {
		        $num_complete++;

			if ($nodownload eq "no")
			{

			unlink (<*.tmp>);

                        @duplist = split(',',$art_partslist{$key});

			$skipfile=-1;

                        foreach $ipart (@duplist)
                        {
				if ( $nodisplay ne "yes" ) {
 					print "\nServer: " . $art_ServerID{$key}{$ipart};
					print " Article_ID: $art_ID{$key}{$ipart} Group: $grp [$art_mult{$key} of";
					print " $art_multnum{$key}] \n";
				}

				$fo = BinaryC($art_ServerID{$key}{$ipart},$art_ID{$key}{$ipart},
                                          $temp_file,$grp,$auth_data);

				if ($fo ne "")
				{
			   		$fname = $fo;
					
                                    	# need to concat dir and filename together in xplatform manner.
			   		if (-e catfile($outdir , $fname))
					{
				  		$skipfile=1;
						$fo="";
				  		last;
					}
				}
			}

			if (($skipfile == -1) && (-e $temp_file) && ($fname ne ""))
				{
				open F, $temp_file or die ("Died trying to open $temp_file\n");
				my($uudecoded_string,$file,$moded) = uudecode(\*F);
				open (F, ">" . catfile($outdir , $fname)) or die("Could Not Open File For Writing: $fname");
				binmode(F);
				print F $uudecoded_string;
				close F;
				chmod oct($moded), $fname;
		 		print q{Decode Complete.. to };
                              	print color 'bold blue';
                              	print  Reasonable("$outdir") .qq{: $fname [} . round($art_size{$key}/1000) . qq{KB]\n};
                              	print color 'reset';
				$fname = "";
				}
				elsif ($fname ne "")
				{
					print "Skipped File ... ";
                              		print color 'yellow';
                              		print qq{$fname [} , round($art_size{$key}/1000) , "KB]\n";
                              		print color 'reset';
					$fname = "";

				}
				else
				{
					print "Skipped Not A Binary.. $key";
					print "[" . round($art_size{$key}/1000) . "KB]\n";

				}


			}
			else
			{
			print color 'bold blue';
			print "[C] $key [";
			print round($art_size{$key}/1000) . "KB] [$art_mult{$key} of $art_multnum{$key}]\n" ;
			print color 'reset';
			}



	}
	elsif ($art_mult{$key} != $art_multnum{$key})
	{
	
		if ( $nodisplay ne "yes" ) {
			print color green;
			print "[I] $key [" . round($art_size{$key}/1000) . "KB] [$art_mult{$key} of $art_multnum{$key}]\n";
			print color 'reset';
		}
	}
	  $numbins_total++;

      }

      print "\nSearched For:";
      print color 'magenta';	
      print " $regex \n";
      print color 'reset';
      print "\nStats:\n";
      print "Binaries Files: [$numbins_total]\n";
      print "Total Articles: [$gnumart_total]\n";
      print "Total Complete Binaries: [$num_complete]\n";
      print "Exiting NewsBinder\n";
      exit;






############################ Helper Function Below #################################################


sub BinaryC($$$$$)
{

my ($nc, @temp, $line, $mode);
my $file="";

my $server   = $_[0];
my $ID       = $_[1];
my $filename = $_[2];
my $group    = $_[3];
my ($authID,$authPW)  = split( /,\s?/,$_[4] );

$nc = new News::NNTPClient($server,119);
$nc->authinfo($authID,$authPW) unless ! $authID;
$nc->mode_reader();
$nc->group($group);

@temp = $nc->body($ID);


open (FILEHANDLEB,">>$filename") or
     die "Can't Open $filename For Append/Output\n";

     foreach $line (@temp) {
        if (index(lc($line),'begin') != -1)
	{
	   $line = substr(lc($line),index(lc($line),'begin'));
	   $_ = $line;
	   ($mode,$file)= /^begin\s*(\d*)\s*(.*)/;
	   $file =~s/\s+//g;
           $file = IsoL8($file);
	   print "FILENAME -> $file\n";
        }
        if ($line ne '\n') {
           print FILEHANDLEB $line;
        }



     }

 close(FILEHANDLEB);

 $nc->quit();

 if ($file ne '') {
     return $file;
 }
 else {
     return "";
 }

}

sub round($) {
#   Input Number to round : Returns rounded number
    my($number) = shift;
    return int($number + .5);
}

sub artgraber($$$)
{
   my $grpSpec   = shift @_;
   my $news_host = shift @_;
   my ($nc, $fmt, $subject_line, $artkey);
   my $cindex = 1; # Article number is the first element Overformat is soon after it
   my $fbracket = 0;
   my $lbracket = 0;
   my $subtotal = 0;

   my ($uName,$pWord) = split( /,\s?/,shift(@_) );
   my ($lb, $rb, $isb, $subp);
   my $numart_total = 0;
   my $nodup = 1;

   my %arthash = ();
   my %xoverfmt = (ID, 0);

   my @multipart; # [0] = Article Part Number / [1] = Number of Total Parts
   my @multiset = ();
   my @fields = ();


   my $myindex= 0;

   $nc = new News::NNTPClient($news_host,119);
   $nc->authinfo($uName,$pWord) unless ! $uName;

   #print "( $news_host ) <BR>\n";

   $nc->mode_reader();

   #$temp print $nc->message;

   foreach $fmt ($nc->list("overview.fmt"))
   {
        chomp $fmt;
        $xoverfmt{$fmt} = $cindex;
        $cindex++;
   }


    $cindex = 0;

    # print @temp;
    # print $nc->message . "<BR>";
   if ( $nodisplay ne "yes" ) {
    	print "Group: $grpSpec\n";
    }

   # Mark: This code should be run and rerun on groups from different servers

  foreach $xover ($nc->xover($nc->group($grpSpec)))
    {

      # print $nc->message;
      $numart_total++;

      chomp $xover;

      @fields = split /\t/,$xover;

      $subject_line = $fields[$xoverfmt{'Subject:'}];

      #print $fields[$xoverfmt{'ID'}] ."\n";

      $fbracket = rindex($subject_line,'(');
      $lbracket = rindex($subject_line,')');

      if (($lbracket == -1 ) || ($fbracket == -1)) {

           $fbracket = rindex($subject_line,'[');
           $lbracket = rindex($subject_line,']');
      }


      if (($lbracket > -1 ) && ( $fbracket > -1)) {


        $subtotal = substr($subject_line,$fbracket+1,($lbracket - $fbracket)-1);

          if (rindex($subtotal,'/') > -1) {

               $artkey = $subject_line;

               if ($fbracket ne '[') {
               	   $artkey =~ s/$subtotal//;
               }
               else {
                   $artkey =~ s/\$subtotal//;
               }

               @multipart= split('/',$subtotal);

               $multipart[0] = int($multipart[0]);  #int(substr($multipart[0],1));

               $multipart[1] = int($multipart[1]);
		#~ s/$brac//;

                chomp $artkey;

                $artkey =~ s/^\s+//;

		# Inserted HERE
		$lb = index($artkey,'[');
		$rb = index($artkey,']');
		$isl = index($artkey,'/');
		$subp = substr($artkey,$lb+1,($rb-$lb)-1);


		#	print $multiset[0] . "\n";
		#	exit;



		if ((($lb != -1) && ($rb != -1)) && (($isl >= $lb) && ($isl <= $rb))) {
		        @multiset = split('/',$subp);
			$multiset[0] =~s/\[//;
			$multiset[1] =~s/\]//;
			$multiset[0] = int($multiset[0]);
			$multiset[1] = int($multiset[1]);

			$myindex= $myindex + 17; # For Color Values


			if (int($multiset[1]) >= int($multiset[0]))
			{
				$setkey = substr($artkey,0,$lb-1);
				$art_sets{$artkey} = $setkey;
				$art_setcolor{$art_sets{$artkey}} = "aacc" .$myindex;
				if ($myindex > 255) {$myindex = 0;}
         		}

		}


		#End HERE

#		print "<B> $artkey </B><BR>\n";

               if (exists($art_mult{$artkey}))
		{

                    @duplist = split (',', $art_partslist{$artkey});
                    @duplist = sort {$a <=> $b} @duplist;

                    for ($cindex = 0;$cindex <= $#duplist;$cindex++)
                    {
                     if ($duplist[$cindex] != $multipart[0]) {
                          $nodup = 1;
                         }
                     else{
                          $nodup = 0;
                          last;
                       }
                    }



                     if ($nodup != 0)
                       {
                         $art_mult{$artkey}+=1;
                         $nodup=1;
                         $art_partslist{$artkey} = join( ",",@duplist) . "," . $multipart[0];
                         $art_ID{$artkey}{$multipart[0]} = $fields[$xoverfmt{'ID'}];
                         $art_ServerID{$artkey}{$multipart[0]} = $news_host; # ? Might need to creat a unique ID here
                         @duplist = split (',', $art_partslist{$artkey});
                         @duplist = sort {$a <=> $b} @duplist;
                         $art_partslist{$artkey} = join( ",",@duplist);
                         $art_size{"$artkey"}+=$fields[$xoverfmt{'Bytes:'}];

                         	if ($duplist[0] == 0)
                         	{
                             		$art_mult{$artkey}-=1;
                         	}

                        }

               }
               else {
                    $art_mult{$artkey} = 1;
                    $art_multnum{$artkey} = int($multipart[1]);
                    $art_partslist{$artkey} = $multipart[0];
                    $art_ID{$artkey}{$multipart[0]} = $fields[$xoverfmt{'ID'}];
                    $art_ServerID{$artkey}{$multipart[0]} = $news_host; # ? Might need to creat a unique ID here
                    $art_size{"$artkey"}+=$fields[$xoverfmt{'Bytes:'}];
		}



              }

      }

   }


  # print "OK... Done!   $numart_total\n";

   $gnumart_total+=int($numart_total);

   #$numbins_total = 0;
   $numart_total = 0;
   #$num_complete = 0;
   $cindex = 1; # Article number is the first element Overformat is soon after it
   $nodup = 1;

   $nc->quit;
   
   if ( $nodisplay ne "yes" ) {
   	print "Done!!!\n" ;
   }
}

sub getgrouplist($$$)
{
   $arg1 = @_[0];
   $arg2 = @_[1];
   $arg3 = @_[2];

   # arg1 =  hostname
   # arg2 =  port
   #arg3 =  filepath

   my $nc = new News::NNTPClient($arg1,$arg2);

   # print $nc->message;

   my @ngroups = $nc->list;

        $filename = $nc->host;

  open (FILEHANDLE, ">". $arg3 . $filename )
   or die ("Cannot open file ". $filename." for Output");

   print FILEHANDLE @ngroups;

   close FILEHANDLE;

   #print $nc->message;

   $nc->quit;
   #print $nc->message;
}

#--------- SUBS ADDED BY SOREN ANDERSEN  Mon Jul 30 2001 ---------

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#   truncates the directory part of output filename so progress display is more readable.
#   this is also a bit of a hack; need to find more robust way of getting COLUMNS for dispaly.
sub Reasonable  {
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

my $str = shift;
my $conswidth = ($ENV{COLUMNS})? $ENV{COLUMNS} : 72;
 #Decode Complete.. /cdv/d/var/nntp_articles/alt.binaries.pictures.gardens posey726c.jpg [153KB]

  if (length($str) > $conswidth - 42 ) {
     $str = q[(...)]. substr( $str, length($str)-31 );
  }
 return $str;
}


sub IsoL8  {

my $purported = shift;
 if ($purported !~m@(/|\\)@)   {
   ;  # do nothing
 } else {
   my $dsep = $1; $dsep =~s@\\@\\\\@;
   $purported = (split($dsep,$purported))[-1];
 }
   return $purported;
}
