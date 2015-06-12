#!/usr/bin/perl
require 'cgi-lib.pl';

&ReadParse(*input);

sub tablehead();
sub tableitem($$);
sub tableend();

print &PrintHeader;
print &HtmlTop ("NewsBinder");

my $temp;
my @parts;
my $query = $input{'query'};
my $qtq='"';

   #print length($query);

if (length($query) == 0) {
   print "<HEAD><meta HTTP-EQUIV=REFRESH CONTENT=$qtq 0;URL=http://192.168.0.3?noquery=true$qtq></HEAD>";
   print &HtmlBot;
   exit;
}

my $numart=0;
my $nothingfound = 1;

open (FILEHANDLE_READ, "<newslist.txt")
     or die ("Cannot open file $news_servers for Output");

while (<FILEHANDLE_READ>) {
   chomp ;
   $temp = $_;  #readline(FILEHANDLE);
   
   if ($temp =~ /.*$query.*/) {

      @parts = split(' ',$temp);

      if ($nothingfound == 1) {
         print tablehead();
      }
      

      $nothingfound = 0;

      if (int($parts[1]) < int($parts[2]))
      {
          $numart = 0;
      }
      else
      {
          $numart = int($parts[1]) - int($parts[2]);
      }
         tableitem($parts[0],$numart);

         
         #print "<A href=http://24.15.161.101/cgi-bin/next.cgi?group=". $parts[0]  .
         #"> $parts[0] </A> $numart <BR>\n";
      }




   
   
   }

close(FILEHANDLE_READ);

tableend();

if ($nothingfound == 1)
{
   print "<center>";
   print "No groups were found that match your query.\n<BR>";
   print "<a href=http://192.168.0.3>Search Again</A>\n";
   print "</center>";
}




print &HtmlBot;
exit;

sub tablehead()
{

  return "<table width=100% border=1 cellpadding=0 cellspacing=0>
                 <tr><td width=100%>
                    <table cellspacing=0 cellpadding=0 width=100%>
                       <tr><td align=left valign=top bgcolor=ff9900 width=40%>
                       <font size=-1><b>Groups</b></font></td>
                       <td bgcolor=ff9900 align=left valign=top width=35%>
                       <font size=-1><b># of Articles</b></font></td>
                       <td bgcolor=ff9900 align=left valign=top width=25%>
                       <font size=-1><b># of Supported Servers</b></font></td></tr>
                    </table>
                 </td></tr>
                 <tr><td width=100%>
                 <table border=1 bordercolor=ffffff cellspacing=0 cellpadding=0 width=100%>\n";
}




sub tableitem($$)
{
                   print " <tr><td align=left valign=top bgcolor=eeeeee width=40%>
                      <font size=1>
                      <a href=next.cgi?group=$_[0] >$_[0]</a>
                      </font>
                      </td>
                      <td bgcolor=eeeeee align=left valign=top width=35%>
                      <font size=1>$_[1]</font>
                      </td>
                      <td bgcolor=eeeeee align=left valign=top width=25%>
                      <font size=1>NA</font>
                      </td></tr>\n"


}


sub tableend()
{

print "</table></td></tr></table>\n";



}
