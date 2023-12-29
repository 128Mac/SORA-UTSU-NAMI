#!/usr/bin/env bash

# 4桁16進数の文字化

reg='([{][\\]GWI[{]u)([[:xdigit:]]{4})([}][}])'

rg -N -I --glob '*.tex' "$reg"                                  |
   perl -Mutf8 -CSD -npe 's/'$reg'/\nNEED-STRING $1 $2 $3 \n/g' |
   rg NEED-STRING                                               |
   perl -Mutf8 -CSD -npe 's/([{}])/[$1]/g;s/(\\)/$1$1$1$1/g'    |
   LANG=C sort -u                                               |
   while read ignore pa pb pc ; do
      ch=$( echo $pb | ruby -ane 'puts $F[0].to_i(16).chr(Encoding::UTF_8)' )
      tt=$( rg -l --glob '*.tex' --sort path -e "$pa$pb$pc" . )
      for t in $tt ; do
         perl -Mutf8 -CSD -i -npe 's/'$pa$pb$pc'/'$ch'/g' $t
      done
      git diff -U0
      git commit -m "GWI で指定する4桁16進数 $pb を $ch に変更" $tt
   done
