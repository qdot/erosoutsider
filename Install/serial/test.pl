# Created by Makefile.PL
# VERSION 0.19

use Test::Harness;
runtests ("t/test1.t", "t/test2.t", "t/test3.t", "t/test4.t",
	  "t/test5.t", "t/test6.t", "t/test7.t");

print "\nTo run individual tests, type:\n";
print "    C:\> perl t/test1.t Page_Pause_Time (0..5) [ COM1 ]\n";
print "\nContinue with 'perl t/test2.t' through 'perl t/test7.t'\n";
print "See README and other documentation for additional information.\n\n";
