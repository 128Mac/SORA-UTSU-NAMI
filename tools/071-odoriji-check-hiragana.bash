#!/usr/bin/env bash

ruby -an tools/072-odoriji-check.rb /dev/null |
    while read -r t1 ign t2 ; do
       tt=$(rg -l --sort path -e "$t1" source/)
       for t in $tt ; do
           ruby -pn -e "\$_.gsub!(/$t1/, '$t2')" $t |
               diff -U0 $t -
       done
    done
