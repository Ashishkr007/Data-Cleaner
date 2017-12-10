# Data-Cleaner
How do I remove a newline (CR, LF or \r, \n) in between data? 
If you some csv file and having CRLF, LF in between data and you want to create some table (Hive table). You will face issue that some of column have null value.

It’s because line terminator in hive is \n and if and \n or \r coming between data it treating as line terminator before actual line terminator and rest for column is getting null value. 

I tried multiple option like spark, hive serde and many more but I found good with perl. Today I a sharing my Perl script to remove all newline and special characters.

Input:
1407233497,1407233514,bar
1407233498,1407233515,foo
mingstats&fmt=n
1407233499,1407233516,foobar

Expected output:
1407233497,1407233514,bar
1407233498,1407233515,foomingstats&fmt=n
1407233499,1407233516,foobar

How to execute script ?

perl E:\Ashish\DataCleaner\NewlineCleaner.pl E:\Ashish\DataCleaner\Sample Data.csv > E:\Ashish\DataCleaner\OutPut.csv

How to install perl ?
https://www.perl.org/get.html
http://strawberryperl.com/releases.html

