function get-CyberLibrarian
    set title "Unicode（東アジア） - CyberLibrarian"
    set url "https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/e_asia.html"

    for t in html org
        [ -d "$t" ] || mkdir -p $t
    end

    set html html/(basename $url)
    [ -f "$html" ] || curl --silent --location -o $html $url
    set t1 ( \
        cat $html \
        | rg html \
        | awk -F'"' '
    /CJK/   { print $4 }
    /u4e00/ { for ( i = 5; i<= 9 ; i++ ) printf "u%d000\n", i }'
    )

    set t2 (
    find html -iname '*.html' \
        | xargs cat \
        | rg '<li><a href="u' \
        | awk -F'"' '{ print $2}' \
        | perl -Mutf8 -CSD -pne 's/\.html$//'
        )
     set tt ( echo $t1 $t2 | tr ' ' '\n' | sort -u )

    set baseurl (dirname $url)
    for t in $tt
        set turl "$baseurl/$t.html"
        set html html/(basename $turl)
        set org   org/(basename $turl .html).org

        if test ! -f "$html"
            echo curl --silent --location -o $html -R $turl | sh -x
        end

        echo $baseurl/$html > $org
        pandoc --from html --to org $html \
            | perl -Mutf8 -CSD -npe '
        s%http:[^=]+=%%g;
        s%file:[^#]+#%%g;

        s/\[\[([[:xdigit:]]+)\]\[(.)\]\]/$2/;

        s/[[:blank:]]+/ /g;
        s/[[:blank:]|]+$//g;
        s/[-[:blank:]+]+$//g;
        s/^[|][[:blank:]]+//
        ' \
            | tee -a $org
        echo $baseurl/$html >> $org

    end
end
