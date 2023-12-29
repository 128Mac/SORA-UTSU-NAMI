#!/usr/bin/env bash

# https://qiita.com/Takayuki_Nakano/items/8d38beaddb84b488d683
# ひらがなの例

rg -N -I --glob '*.tex' 'ruby[^s]' |
    perl -Mutf8 -CSD -npe '
        s/^[^{]+{//;
        s/}{([\p{sc=hira}\p{sc=kana}[:blank:]]|〳|\\ |[{]*\\GWI).*//g;
        s/([\p{sc=han}\p{sc=hira}\p{sc=kana}])/\n$1\n/g;
        s/\\GWI[{]([^{}]+)[}]+/\n$1/g;
        s/[\p{sc=hira}\p{sc=kana}{}]+/\n/g;
        ' |
        awk '$1 != "i" && NF' |
        LANG=C sort -k 1,2 -k 4 -k 3 |
        uniq |
        ruby -ane '
        unicode = $F[0]
        if unicode =~ /^[\p{Han}]$/ then
           searchkey = "u" + unicode.ord.to_s(16)
        else
           if unicode =~ /^u/ then
               searchkey = unicode.sub(/-.*/, "")
           else
               searchkey = unicode
           end
        end
        printf( "%s %s\n", unicode, searchkey )
        ' |
        while read unicode searchkey ; do
            (
                echo $unicode
                curl --silent --location 'https://glyphwiki.org/wiki/'$searchkey |
                    perl -Mutf8 -CSD -0777 -npe '
                    s/.*<h1>([^ ]+) <span[^<>]+>([(][^()]+[)]).*/$1 $2/;
                    s/<[^<>]+>//g;
                    s/メタ情報.*//;
                    ' |
                    rg -i $searchkey
            ) | xargs
        done |
        cat ; exit
    awk '$1 != O1 || $2 != O2 { O1=$1; O2=$2; print ""}NR' |
    awk -v RS= '
    NF > 4 || $1 != $4 {
       printf "%s %-6s", $1, $2;
       for ( i = 0 ;  i < NF ; i+=4) printf " %s(%d)", $(i+4), $(i+3);
       print ""
    }
    ' |
    while read a b c ; do
        echo
        echo "** TODO" $a $b $c
        for x in $c ; do
            echo "- [ ]" $x
            grep -r -e "$(echo $x | sed 's/[(].*[)]//')" . | head
        done
    done
