Chinese Tools
=======

Some Chinese related things. (Yes, things...)

##chengyu.txt
The file contains a [chengyu](http://en.wikipedia.org/wiki/Chengyu) for each line.
The chengyus comes from the txt file from [this webpage's download](http://www.txtbz.com/Soft/xxzl/200902/7728.htm).
The original file has more detailed descriptions.

###Example:

Pick a chengyu with "日" as one of the characters, and highlight it with quotes.

 ```bash
 sed -n 's/日/"日"/p' chengyu.txt | sort --random-sort | head -n 1
 ```

_Note: `sort --random-sort` doesn't work on machines without `gnu-coreutils`._

节操尽失.