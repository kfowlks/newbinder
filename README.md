NewsBinder v1.03
Written By Kevin Fowlks July 20th
Contributions From: Soren Andersen
E-mail: kamka@760mp.com
Released Under GPL 

Minor updates v1.06
See History:

Minor updates v1.03
See top of Newbinder.pl for a list of changes.


Description:
NewsBinder is a powerful usenet binary grabber written in Perl 5.
NewsBinder supports the following features: fast downloading,
uudecoding of binary files, assembling of multi-part posts,
Support for merging post from multiply news servers to complete incomplete files,
skipping files that have already been downloaded.

Requirements:
Pentium 333Mhz or Higher
32 Megs Ram Recommend: (256 Megs Ram)
Anything that can run one of the following: e.g. (Linux, Mac OS X).
	Perl 5.005
	NNTPClient Modules
	UU:Convert Modules

(Beta Web Version) Unsupported
Webserver that supports CGI e.g. (Apache) 

How to use?

Well, This program is best used on a high-speed Internet connection e.g. (Cable Modem/DSL/T1). 
You'll, also need a computer that can run Perl 5.005 or higher , lots of disk space for all your downloads helps too. :) 

NewsBinder v1.0  Created By: Kevin Fowlks
usage: ./newsbinder.pl [-v] [-h] [-o] [-l] <-g> substring
         -v or --version (Display Version)
         -h or --help    (Displays This Info Here)
         -o or --output  (Output Directory) * Where to store your decoded files *
         -l or --list    (Displays a lists of all the articles that you might want to download)
         -g or --group   *Required (Selects Group That You Want To Download From )
         -nd or --nodisplay (Only display important info when grabbing binary files)
          substring default is everything (Grabs all articles that match) * Use this to restrict your downloads *
	  
	  
News.ini File

<Updated>

This files contains a list of News Servers that you want to use. The format is either in IP or Hostname.

24.2.68.78
news.rdc1.md.home.com
....etc

or 

news.myserv.com starsky,G76!lab3
news.newsfeed.com	luckdog,winner1212!
		
The server followed by an arbitrary amount of white spaces
(simple spaces or tabs for instance) , followed by the 
username,password. This is for news servers that require authentication i.e
username,password.


Groups.txt
This is a basic list of groups that my news server supports (@home) but most group are very common.

alt.binaries.dawsons-creek 0030090318 0030090316 y
alt.binaries.demo-scene 0030001292 0030001292 y
alt.binaries.demo-scene.ibm-pc 0030005084 0030005082 y
alt.binaries.demos 0030044934 0030044933 y
alt.binaries.demos.ibm-pc 0030014686 0030014685 y
alt.binaries.dereck 0030000069 0030000069 y
alt.binaries.descent 0030093676 0030092482 y
.....etc


How to run this program?

Example Usage:


./newsbinder.pl -g alt.binaries.multimedia.roswell -l  # This displays all the binary files in the
							 group roswell on the console.

./newsbinder.pl -g alt.binaries.multimedia.roswell  -o /tmp/ # This downloads all complete Binarys files
							       from this group and outputs them in /tmp/
							 
./newsbinder.pl -g alt.binaries.multimedia.roswell  -nd -o /tmp/ # This downloads all complete Binarys files
							         from this group and outputs them in /tmp/
								 while only displaying info that is
								 important.
								 
./newsbinder.pl -g alt.binaries.multimedia.roswell  -o /tmp/   .*VCD*. # This downloads all complete 
								        Binarys files from this group
								        that contain the word VCD in it's
									subject and outputs them in /tmp/
							  


Other Planned Features (For Next Major Release 1.X ): 

Watch Capabilities: Newbinders will check news servers every N Minutes to see
if the file that you need to complete is available. 

Incomplete File Save: Give the user the option to save incomplete binary post
(missing articles to decode) So that they can be combined later and decoded.


Questions & Answers?

Question: Why does your Perl code suck? 
Answer: I'm very new to programming in Perl and really don't do it that often. :)

Question: Why don't you do XXXX in your program where XXXX = CCCCC?
Answer: I will continue to update and maintain NewsBinder as much as possible.
The main reason, I released the source code to this project was to get feedback and
patches from more experienced Perl programmers. So if you have a patch please send it to me.
Use my contact info above.

Question: Why write this in Perl, why not C?
Answer: That's easy Perl ROck!! 
I might consider rewriting it in C but it would have to for speed reasons.

Known Problems:

Some times Articles expire before newsbinder gets a chance to download them.
this causes newsbinder to create a zero byte file. This will be fixed in the
next major release.

Unsupported Web Version of this program but that version is depricated.
it is in the beta dir there are not documents on it. It's just there :)P


History:

# July 30th,2001
# Changes Made By : Soren Andersen <soren(at)wonderstorm.com>
# Added: `File::Spec' now used for addressing output directorys added.
# Added:  Sub to get the true output filename minus the directoy path used by some news agents.
# Added:  Support for Term::ANSIColor to get highlighted output.
# Added:  Sub to truncate output to fit screen and not wrap.   

# July 30th,2001
# Changes Made By : Kevin Fowlks <kamka@760mp.com>
# Added: -nd or -nodisplay switch which only displays the essential information on binary files.

# Aug 3rd, 2001
# Changes Made By : Soren Andersen <soren(at)wonderstorm.com>
# Added: News Server Authentication scheme (see readme.txt for details) 
# Change: Made some of the code More perl-ish :) 

# Aug 4th,2001
# Changes Made By : Kevin Fowlks <kamka@760mp.com>
# Fixed : Total number of binary files was broken
# Fixed : Substring search (This should now work the way it was intended :) )
# Added: Search Expression is now shown with the Binary stats.
