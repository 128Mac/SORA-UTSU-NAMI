#!/usr/bin/env 000-setup.bash

tt=$( find source -iname '[0-9]*.tex' | sort )
cat $tt |
    perl -Mutf8 -CSD -npe '
    s/%.*//;s/換字/\n/g;
    s/[^\p{sc=han}\p{sc=hira}]+/\n/g;
    s/^\n+//
    ' |
    ruby -n -e "
    puts \$_              .scan(/.{1,#{2}}/)
    puts \$_.sub(/^./, '').scan(/.{1,#{2}}/)
    " |
    rg .. |
    LANG=C sort -r -u |
    while read cc ; do
        rg -e "$cc[|]*$cc" $tt
    done |
    tr ':' '\t'
    exit
