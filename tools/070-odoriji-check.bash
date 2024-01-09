#!/usr/bin/env bash

cat source/*.tex |
    perl -Mutf8 -CSD -npe '
    s/(換字|々|・)//g;
    s/([^\p{sc=han}]+)//g;
    s/([\p{sc=han}])/\n$1/g;
    ' |
    LANG=C sort -r -u |
    while read t ; do
        [ -n "$t" ] &&
            rg --glob '*.tex' --sort path -e "$t""[|]""*$t" source/
    done |
    perl -Mutf8 -CSD -npe '
    s/([^:]+):\\ruby(.*)/"$2" => "$2",/;
    ' |
    LANG=C sort -r -u
