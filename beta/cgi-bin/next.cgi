#!/usr/bin/perl

# NewsBinder v.01 
# Written By Kevin Fowlks 
# July 20th 2001
# Released Under GPL License


sub tablehead();
sub tableitem($$$$$$);
sub tableend();
sub BinaryC($$$$);
sub round($);
sub artgraber($$);

require 'cgi-lib.pl';

use News::NNTPClient;

&ReadParse(*input);

my $grp = $input{'group'};

 
my $numbins_total = 0;
my $num_complete = 0;
my $gnumbins_total = 0;
my $gnumart_total = 0;
my $gnum_complete = 0;

# Arrays
my @duplist;

# Hash's
my %art_partslist = ();
my %art_mult = ();
my %art_multnum = ();
my %art_ID = ();
my %art_ServerID = ();
my %art_sets = ();
my %art_setcolor = ();
my %art_size = ();

my $news_servers = "news.ini";
my $news_path = "newslist/";
my $setkey;




# Start of News Gather
# Loop thourgh all news servers found in news.ini then proceeds to BIND servers articles together 

# Main Program Here --> begin

# Print "Starting NewsBinder\n";

print &PrintHeader;
print &HtmlTop ("NewsBinder");

 my $nhost;

 open (FILEHANDLE_READ, "<news.ini") 
     or die ("Cannot open file $nhosts for Output");

 $|=1; # Flush Print Outputs

 while (<FILEHANDLE_READ>) {

   $nhost = $_;  #readline(FILEHANDLE);
   chomp $nhost;

   if ($nhost ne '')  {
      print "<B>Reading Host:</B><I>" . $nhost . "</I><BR>\n";
      artgraber($grp,$nhost);
   }
 }

 close FILEHANDLE_READ;

# End of News Gather
my $cindex=0;

print "<FORM ACTION=download.cgi Method=POST>";
print "<input type=hidden VALUE=$grp NAME=group> \n"; 

print tablehead();

open FILEOUT,">OUT.TXT";

   	# Done This is nothing more then a tally of all the binarie files we have
        
	       my $icount=0,$key,$ipart,@fparts;

               foreach $key (sort keys %art_mult)
		{

		print FILEOUT  "$key	$numbins_total\n";

                 if ($art_mult{$key} == $art_multnum{$key})
                    {

                        $num_complete++;

               if ($art_setcolor{$art_sets{$key}} eq "") {
     
     print tableitem($key,"( $art_mult{$key} of $art_multnum{$key})","<B>C</C>","eeeeee",round($art_size{$key}/1000) . "Kb",$numbins_total);

                         }
                         else {
     print tableitem($key,"( $art_mult{$key} of $art_multnum{$key})","<B>C</C>",$art_setcolor{$art_sets{$key}},round($art_size{$key}/1000) . "Kb",$numbins_total);
                         }

                    }
                    else
                    {

if ($art_setcolor{$art_sets{$key}} eq "") {
    	print tableitem($key,"( $art_mult{$key} of $art_multnum{$key})","<B>I</B>","eeeeff",round($art_size{$key}/1000) . "Kb",$key);
    }
    else {
    	print tableitem($key,"( $art_mult{$key} of $art_multnum{$key})","<B>I</B>",$art_setcolor{$art_sets{$key}},round($art_size{$key}/1000) . "Kb",$key);
    }

    		    }

                    $numbins_total+=1;
		
		
               }
	# End of Loop	



	
      close FILEOUT;
      print tableend();

      print "<B>Stats:<B\n";
      print "<BR><BR><BR>\n";
      print "Binaries Files: [$numbins_total]\n<BR>";
      print "Total Articles: [$gnumart_total]\n<BR>";
      print "Total Complete Binaries: [$num_complete]\n<BR>";
      print "Exiting NewsBinder\n<BR><BR>";


   quit;

print "<INPUT TYPE=submit VALUE=Download>\n";
print "</FORM>\n";
print &HtmlBot;
























############################ Helper Function Below #################################################

sub tablehead()
{
 return "<table width=100% border=0 cellpadding=0 cellspacing=0>
 	<tr><td width=100%>
	<table cellspacing=0 cellpadding=0 width=100%>
	<tr>
	<td align=left valign=top  border=1 bordercolor=000000 bgcolor=ff9900 width=5%>
	<font size=-1><b>Status</b></font></td>
	<td bgcolor=ff9900 align=left valign=top width=6%>
	<font size=-1><b>Mark</b></font></td>
	<td bgcolor=ff9900 align=left valign=top width=74%>
	<font size=-1><b>Articles</b></font></td>
	<td bgcolor=ff9900 align=left valign=top width=5%>
	<font size=-1><b>Size</b></font></td>
	<td bgcolor=ff9900 align=left valign=top width=5%>
	<font size=-1><b>D/L</b></font></td>
	<td bgcolor=ff9900 align=left valign=top width=5%>
	<font size=-1><b>B</b></font></td>
	</table>
	</td></tr>
        <tr><td width=100%>
        <table border=1 bordercolor=ffffff cellspacing=0 cellpadding=0 width=100%>\n";
}


sub tableitem($$$$$$)
{
 return "<tr>
 <td align=left valign=top bgcolor=$_[3] width=5%>
 <font size=1>
 <Center>$_[2]<Center>
 </font>
 </td>
 <td bgcolor=$_[3] align=left valign=top width=6%>
 <font size=1>$_[1]</font>
 </td>
 <td bgcolor=$_[3] align=left valign=top width=74%>
 <font size=1>
 $_[0]
 </font>
 </td>
 <td bgcolor=$_[3] align=left valign=top width=5%>
 <font size=1>
 $_[4]
 </font>
 </td>
 <td bgcolor=$_[3] align=left valign=top width=5%>
 <font size=1>
 <input type=checkbox NAME=dlgroups value=',$_[5]' >
 </font>
 </td>
 <td bgcolor=$_[3] align=left valign=top width=5%>
 <font size=1>
 <input type=checkbox name= >
 </font>
 </td>
 </tr>\n";
}


sub tableend()
{
  return "</table></td></tr></table>";
}


sub BinaryC($$$$)
{
# server,ID,filename,group
my $server;
my $nc;
my $filename;
my $ID;
my $group;
my @temp;
my $line;
my $go;

$server = $_[0];
$ID = $_[1];
$filename = $_[2];
$group = $_[3];
$go = 0;
$nc = new News::NNTPClient($server,119);
$nc->mode_reader();
$nc->group($group);
@temp = $nc->body($ID);

open (FILEHANDLEB,">>$filename") or
     die ("Can't open $filename for Append/Output\n");

     foreach $line (@temp) {
        if (index($line,'begin') != -1) {
           $go=1;
        }        
        if (($line ne '\n') && ($go = 1)) {
           print FILEHANDLEB $line;
        }
     }
#print $nc->message . "( $news_host ) <BR>\n";
close(FILEHANDLEB);
$nc->quit();
}

sub round($) {
    my($number) = shift;
    return int($number + .5);
}

sub artgraber($$)
{
   my $nc,$fmt;
   my $cindex = 1; # Article number is the first element Overformat is soon after it
   my $subject_line;	
   my $fbracket; 
   my $lbracket;
   my $subtotal;
   my $artkey;
   my $news_host == $_[1];
   my $lb,$rb,$isb,$subp;
   my $numart_total = 0;
   my $nodup = 1;

   my %arthash = ();
   my %xoverfmt = (ID, 0);
   
   my @multipart; # [0] = Article Part Number / [1] = Number of Total Parts
   my @multiset; 
   my @fields;


   my $myindex= 0;
 
   $nc = new News::NNTPClient($news_host,119);

   #print "( $news_host ) <BR>\n";

   $nc->mode_reader();

   #$temp print $nc->message;

   foreach $fmt ($nc->list("overview.fmt"))
   {
        chomp $fmt;
        $xoverfmt{$fmt} = $cindex;
        $cindex++;
   }

   $cindex=0;

  # print @temp;
  # print $nc->message . "<BR>";


    print "<B>Group:</B>" . $_[0] . "<BR>\n";
   
   # Mark: This code should be run and rerun on groups form differnt servers
 
  foreach $xover ($nc->xover($nc->group($_[0])))
    {

      # print $nc->message;
      $numart_total++;

      chomp $xover;

      @fields = split /\t/,$xover;

      $subject_line = $fields[$xoverfmt{'Subject:'}];

      #print $fields[$xoverfmt{'ID'}] ."\n";

      $fbracket = rindex($subject_line,'(');
      $lbracket = rindex($subject_line,')');

      if (($lbracket == -1 ) || ($rbracket == -1)) {
      
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

               # $multipart[1] =~ s/$brac//;

               chomp $artkey;

               $artkey =~ s/^\s+//;

		# Inserted HERE
		$lb = index($artkey,'[');
		$rb = index($artkey,']');		
		$isl = index($artkey,'/');
		$subp = substr($artkey,$lb+1,($rb-$lb)-1);
		
	
		
		if ((($lb != -1) && ($rb != -1)) && (($isl >= $lb) && ($isl <= $rb))) {
		      
			$myindex= $myindex + 17; # For Color Values
			
			@multiset = split('/',$subp);
			$multiset[0] =~s/\[//;
			$multiset[1] =~s/\]//;
			$multiset[0] = int($multiset[0]);
			$multiset[1] = int($multiset[1]);
	
			if (int($multiset[1]) >= int($multiset[0]))
			{
				$setkey = substr($artkey,0,$lb-1);
				$art_sets{$artkey} = $setkey;
				$art_setcolor{$art_sets{$artkey}} = "aacc" .$myindex;
				if ($myindex > 255) {$myindex = 0;}
         		}
         		
		}
		
		if ((index(lc($artkey),'file') != -1) && (index($artkey,'of') != -1))
		{
			#print "<H2>I'm HERE</H2>\n";
				
				if (exists($art_sets{$artkey}) < 1) { 
				$myindex= $myindex + 50; # For Color Values

					$setkey = substr($artkey,0,index(lc($artkey),'file'));		
					$art_sets{$artkey} = $setkey;
					$art_setcolor{$art_sets{$artkey}} = "aaccff";
				}
	
				if ($myindex > 255) {$myindex = 0;}
		}	
		

		#End HERE



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
                    $art_multnum{$artkey}   = int($multipart[1]);
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
   print "<B>Done!!!</B><BR><BR>\n" ;


}

