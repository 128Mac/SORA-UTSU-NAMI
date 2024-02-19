function CHAR-2-UNICODEEPOINT
    ruby -e '
    ARGV.each do | av |
    av.each_codepoint do | ch |
    puts ch.chr(Encoding::UTF_8) + " " +  ch.to_s(16)
end
end
' $argv
end

function UNICODEEPOINT-2-CHAR
    ruby -e 'ARGV.each do | av |
    puts av.downcase + " " + av.hex.chr(Encoding::UTF_8) + " "
end
' $argv
end

function PANDOC-0g0-org
    set cpcp (
        ruby -e '
            BEGIN { array = [] }
            ARGV.each do | av |
                av.each_codepoint do | ch |
                    array.push( ch.to_s(16) )
                end
            end
            END { puts array.uniq }
        ' $argv
    )
    for cp in $cpcp
        [ -d PANDOC-0g0-org ] || mkdir PANDOC-0g0-org

        set html PANDOC-0g0-org/(UNICODEEPOINT-2-CHAR $cp | xargs | tr ' ' '-').html
        set org  PANDOC-0g0-org/(UNICODEEPOINT-2-CHAR $cp | xargs | tr ' ' '-').org
        set url  https://0g0.org/unicode/$cp/

        [ -f "$html" ] || curl --silent --location -o $html $url
        [ -f "$html" ] || continue

        echo
        pandoc -f html -t org $html |
             rg -v                                     \
                -e '0g0.org'                           \
                -e '^:'                                \
                -e '^__'                               \
                -e 'https://'                          \
                -e 一覧とURLエンコード検索・変換サイト \
                -e このサイトについて                  \
                -e お問い合わせフォーム                \
                -e 文字をクリップボードにコピー        \
                |
            uniq |
            perl -Mutf8 -CSD -0777 -npe '
                my $re = join( "|"
                    , "Unicode"
                    , "分類"
                    , "数値文字参照"
                    , "URLエンコード[(]UTF-8[)]"
                    , "URLエンコード[(]EUC-JP[)]"
                    , "URLエンコード[(]SHIFT_JIS[)]"
                    , "ユニコード名"
                    , "一般カテゴリ－"
                );
                s/($re)\n+([^\n]+)\n+/| $1 | $2 |\n/g;
            ' | tee $org
            echo "<<< $url >>><<< file://$org >>>"
    end
end

function SHINJI-KYUUJI-type01
    pandoc -f html -t org $argv[1] 2>/dev/null |
       perl -Mutf8 -CSD -ne '
           # www.benricho.org.html
           # [[javascript:ShowBigCharacter('fa4d','新字体：祉')][祉(祉)]]
           #                                           1     2
           printf "$1 $2\n" if ( /ShowBigCharacter.*\[(.)[(](.)[)]\]\]/ ) ;
           '
end

function SHINJI-KYUUJI-type02
    pandoc -f html -t org $argv[1] 2>/dev/null |
       perl -Mutf8 -CSD -ne '
           # kanji.jitenon.jp.html
           # - [[https://kanji.jitenon.jp/kanjim/6396.html][祉（祉）]]
           #                       1111111111    2222222222
           printf "$2 $1\n" if ( /(\p{sc=han})（(\p{sc=han})）/         ) ;

           # erid.nier.go.jp
           # | 労   | 勞   |
           #                          1111111111        2222222222
           print "$1 $2\n" if ( /[|] (\p{sc=han}) +[|] (\p{sc=han}) +[|]/ ) ;

           # https://seesaawiki.jp/7%C9%BD
           # 祉 祉\\

           # 湾 灣
           #                       1111111111   2222222222
           print "$1 $2\n" if ( /^(\p{sc=han}) (\p{sc=han})\\\\*/ );
           '
end

function SHINJI-KYUUJI-type03
    pandoc -f html -t org $argv[1] 2>/dev/null |
        perl -Mutf8 -CSD -npe '
            # www.asahi-net.or.jp の場合のデータ補正
            s/([^\p{sc=han}] [|] \p{sc=han} [|])\n/$1/;
        ' |
        perl -Mutf8 -CSD -ne '
            # www.asahi-net.or.jp.html
            # | | 3B3F | 8CDB | 賛 | 贊 | ... | 3B63 | 7949 | 祉 | 祉 | 7934 | FA4D    |
            s/[[:blank:]]+/ /g;
            if ( / [|[:xdigit:]]+ [|] \p{sc=han} [|] \p{sc=han}/ ) {
            ##if ( / [|[:xdigit:]]+[[:blank:]]+[|] \p{sc=han} [|] \p{sc=han}/ )
                 s/ *[[:xdigit:]]+ *//g;
                 s/[| ]+//g;
                 s/\n//;
                 s/(\p{sc=han})(\p{sc=han})/$1 $2\n/g;
                 print $_;
            }
        '
end

function SHINJI-KYUUJI-type04
    pandoc -f html -t org $argv[1] 2>/dev/null |
        perl -Mutf8 -CSD -0777 -ne '
            s/[[:blank:]]+/ /g;
            s/([|]) [*]*[\[]+file:[^ ]+[*]*(\p{sc=han})[*]*[\]\[]+[*]*/$1 $2/g;
            s/([|] ){2}([*][新旧]字[*][^\n]+)( [|]){12}\n/$2\n/g;
            my $re = "([|]) ([^ ]) ([|]) ([|])";
            my $cnt = 5;
            while  ( /$re/ && $cnt > 0 ) {
                s/$re/$1 $2 $3 $2 $4/g;
                $cnt -= 1;
            }
            s/ [|]\n/\n/g;
            s/([*]旧字[*][^\n]+)\n/\n$1 | /g;
            s/ [|] / /g;

            my @ll = split( "\n" );
            for ( my $lli = 1; $lli <= @ll ; $lli++ ) {
                next unless ( @ll[$lli] =~ /[*]旧字[*]/ );

                my @ar = split( " ", $ll[$lli] );
                for( my $i = 1; $i < @ar/2; $i ++ ) {
                print "$ar[$i + @ar/2] $ar[$i]\n"
                }
            }
        '
end

function SHINJI-KYUUJI-type05
    pandoc -f html -t org $argv[1] 2>/dev/null |
        perl -Mutf8 -CSD -ne '
            if ( /亜亞/ ) {
                s/(\p{sc=han})(\p{sc=han})/$1 $2/g;
                s@/@\n@g;
                print;
            }
            '
end

function SHINJI-KYUUJI-type10
    pandoc -f html -t org $argv[1] 2>/dev/null |
    perl -Mutf8 -CSD -0777 -ne '
        s/:[^:]+[^|]+//g;
        s/[\\\\*]+//g;
        s/([|] +){2,}//g;
        s/[[:blank:]]+/ /g;
        s/\n//g;
        s/(新字)/\n$1/g;
        s/[A-Z] [|]+[^\n]+//g;
        s/[|]+//g;
        s/<<totop>[^\n]+\n//;

        my @li = split("\n");
        for ( my $li = 1 ; $li <= @li ; $li++ ) {
             my @ar = split( " ", @li[$li] );
             for ( my $i = 1; $i < @ar/2 ; $i++ ) {
                 # 新字と旧字がおなじ 塚 晴 朗 猪 益 神 祥 精 諸 逸 隆 靖 飯 飼 館
                 print "$ar[$i] $ar[$i + @ar/2]\n" if ( $ar[$i] ne $ar[$i + @ar/2] );
             }
        }
    '
end

function SHINJI-KYUUJI-type12
    pandoc -f html -t org $argv[1] 2>/dev/null |
    perl -Mutf8 -CSD -0777 -ne '
        s/[|] [|] ([*][新旧][*][^\n]+)[|]\n/$1\n/g;
        s/([*]新[*][^\n]+)\n/$1 /g;
        s/[[:blank:]]+/ /g;
        while ( /[|] \p{sc=han} [|] [|]/ ) {
            s/([|]) (\p{sc=han}) ([|]) ([|])/$1 $2 $3 $2 $4/g;
        }
        s/[|] //g;
        s/[^\n]+JISコード順[^\n]+//;
        my @ll = split( "\n" );
        for ( my $lli = 1; $lli <= @ll ; $lli++ ) {
            my @ar = split( " ", $ll[$lli] );
            for( my $i = 1; $i < @ar/2; $i ++ ) {
                print "$ar[$i] $ar[$i + @ar/2]\n"
            }
        }
    '
end

function SHINJI-KYUUJI-typeXX
    # echo ==== not inprement for $argv[1] ====
end

function SHINJI-KYUUJI-typeY
    pandoc -f html -t org $argv[1] 2>/dev/null
end

function SHINJI-KYUUJI-typeZ
    # https://www.tobunken.go.jp/archives/異体字リスト/
    set html PANDOC-0g0-org/SHINJI-KYUUJI-www.tobunken.go.jp.html
    pandoc -f html -t org $html 2>/dev/null |
        rg '^[|]'                           |
        rg -e $argv[1]                      |
        tr -s '| ' '\n'                     |
        LANG=C sort -u                      |
        xargs                               |
        rg -e $argv[1]
end

function SHINJI-KYUUJI-typeZZ
    set html PANDOC-0g0-org/SHINJI-KYUUJI-eiichi.shibusawa.or.jp.html
    pandoc -f html -t org $html 2>/dev/null |
    rg '[|] \p{sc=han} ' |
    perl -Mutf8 -CSD -npe '
    chomp;
    s/[^\p{han}\p{sc=hira}\p{sc=kana}\n]+/ /g;
    s/ *(\p{sc=han}) (\p{sc=han}) ([\p{sc=hira}\p{sc=kana} ]+)/$2 $1 $3\n/g;
    print;
    ' |
    LANG=C sort -u
end

function SHINJI-KYUUJI
    [ -d PANDOC-0g0-org ] || mkdir PANDOC-0g0-org

    set urls[ 1]  'https://www.benricho.org/moji_conv/14_shin_kyu_kanji.html'
    #             'https://www.benricho.org/moji_conv/13-kyuji.html'
    set urls[ 2]  'https://kanji.jitenon.jp/genre/28' # 旧字体・新字体一覧
    set urls[ 3]  'https://www.asahi-net.or.jp/~ax2s-kmtn/ref/old_chara.html'
    set urls[ 4]  'https://okjiten.jp/11-sinjikyuuji.html'
    set urls[ 5]  'https://sound.jp/mtnest/k/kyuji-all1.htm'
    set urls[ 6]  'https://erid.nier.go.jp/kanji.html' # 「学習指導要領のデータベース」教科書用？なので 88 件と少ない
    set urls[ 7]  'https://dictionary.sanseido-publ.co.jp/columncat/漢字/人名用漢字の新字旧字'
    set urls[ 8]  'https://www.tobunken.go.jp/archives/異体字リスト/'
    set urls[ 9]  'https://eiichi.shibusawa.or.jp/denkishiryo/digital/main/index.php?kanji'
    set urls[10]  'https://www.rakuten.ne.jp/gold/hanko2510/oldfont.html'
    set urls[11]  'https://seesaawiki.jp/ryakuji/d/%BF%B7%BB%FA%C2%CE%B5%EC%BB%FA%C2%CE%C2%D0%B1%FE%B0%EC%CD%F7%C9%BD'
    set urls[12] 'http://www2.japanriver.or.jp/search_kasen/search_help/refer_kanji.htm' # 辺 邊 邉

    for url in $urls
        set html ( echo $url | awk -F'/+' '{ print $2 }' )
        set outH PANDOC-0g0-org/SHINJI-KYUUJI-$html.html
        [ -f "$outH" ] || curl --silent --location "$url" | nkf -Lu -w > $outH
    end

    set idx 0
    for url in $urls
        set idx  ( math $idx + 1 )
        set html ( echo $url | awk -F'/+' '{ print $2 }' )
        set outH PANDOC-0g0-org/SHINJI-KYUUJI-$html.html
        set outO PANDOC-0g0-org/SHINJI-KYUUJI-$html.org

        switch "$url"
            case "$urls[ 1]" ; SHINJI-KYUUJI-type01 $outH ;
            case "$urls[ 2]" ; SHINJI-KYUUJI-type02 $outH ;
            case "$urls[ 3]" ; SHINJI-KYUUJI-type03 $outH ;
            case "$urls[ 4]" ; SHINJI-KYUUJI-type04 $outH ; # 'https://okjiten.jp/11-sinjikyuuji.html'
            case "$urls[ 5]" ; SHINJI-KYUUJI-type05 $outH ; # 'https://sound.jp/mtnest/k/kyuji-all1.htm'
            case "$urls[ 6]" ; SHINJI-KYUUJI-type02 $outH ; # 'https://erid.nier.go.jp/kanji.html'
            case "$urls[ 7]" ; SHINJI-KYUUJI-typeXX $outH ; # 'https://www.tobunken.go.jp/archives/異体字リスト/'
            case "$urls[ 8]" ; SHINJI-KYUUJI-typeXX $outH ; # 'https://dictionary.sanseido-publ.co.jp/
            case "$urls[ 9]" ; SHINJI-KYUUJI-typeXX $outH ; # 'https://eiichi.shibusawa.or.jp/
            case "$urls[10]" ; SHINJI-KYUUJI-type10 $outH ; # 'https://www.rakuten.ne.jp/
            case "$urls[11]" ; SHINJI-KYUUJI-type02 $outH ; # 'https://seesaawiki.jp/7%C9%BD'
            case "$urls[12]" ; SHINJI-KYUUJI-type12 $outH ; # 'http://www2.japanriver.or.jp
        end | awk '{ printf "%s (%02d)\n", $0, '$idx' }'
    end |
        LANG=C sort  |
        awk '$1 != O1 || $2 != O2 { O1 = $1; O2 = $2; print "" }NR' |
        awk -v RS= '
        {
             printf "%s %s %s", $1, $2, $3;
             for ( i = 3+3; i <= NF ; i+=3 )
                 printf ",%s", $i;
             print ""
        }
        ' |
        awk '$1 != O1 { O1 = $1; print "" } NR'
    set idx 0
    echo
    for url in $urls
        set idx  ( math $idx + 1 )
        printf "(%02d) %s\n" $idx $urls[$idx]
    end

end

function DICGEN
    echo $argv[1] $argv[2]

    set useragent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.74 Safari/537.36"
    ruby -e '('$argv[1]' .. '$argv[2]').each { |t| printf "%s %s\n", t.to_s(16), t.chr(Encoding::UTF_8) }' |
    while read a b
        set url https://dictionary.goo.ne.jp/word/kanji/$b/

        set sleeptime (random 2 2 45);
        echo
        echo (date '+%F %T') $a $b $url
        echo (date '+%F %T') sleep $sleeptime
        sleep $sleeptime;

        # --user-agent $useragent
        while true
            curl --silent --location  $url |
            pandoc -f html -t org 2> /dev/null|
            sed  '1,/<<NR-main>>/d;/同じ.*漢字/,$d' > dic/$a-$b.dic.org

            rg 画像内に表示されている英数字 dic/$a-$b.dic.org || break

            set sleeptime 1800
            echo (date '+%F %T') 警告メッセージが表示されたので $sleeptime 秒 sleep
            sleep $sleeptime
        end
        echo (date '+%F %T') done
    end
end

function DICGENedit
    for t in $argv
        perl -Mutf8 -CSD -0777 -npe '

        s/[\[][\[][^\[\]\n]+[\]][\[]([^\[\]]+)[\]\n][\]]/$1/g;
        s/[\[][\[][^\[\]\n]+[\]][\]] *//g;
        s/\nブックマークへ登録//g;
        s/<<[^<>\n]+>>//g;
        s/\n:[^\n]+//g;
        s/\n([1-9].*[*])\n/\n$1/g;
        s/\n\n+/\n\n/g;
        ' $t
    end
end


function goodic
    set urlgoo https://dictionary.goo.ne.jp/srch/all
    for t in $argv
        set enc (
        ruby -r uri -e '
        ARGV.each{|c|puts URI.encode_www_form_component(c)}
        ' $t
        )
        curl --silent --location $urlgoo/$enc/m0u/ |
        nkf -w -Lu |
        pandoc -f html -t plain 2>/dev/null |
        sed '
        /^-[[:blank:]]*$/{ N; N; s/[[:space:]][[:space:]]*/ /g};
        s/^[2-9][.].*//;

        1,/^[1][.]/d;
        /^[1][.]/,/世界の名言・格言/d;

        /[０-９]/{N; s/\n[[:blank:]]*/ /};
        /もっと調べる/d;
        /もっと見る/,$d;
        ' | uniq
    end
end

function kanjipedia
    set url1 'https://www.kanjipedia.jp/search/?k='
    set url2 'URLエンコードされた情報を入れる'
    set url3 '&kt=1&wt=1&ky=1&wy=1&sk=partial&t=kotoba'
    # https://www.kanjipedia.jp/search/?k=%E8%A8%BA%E6%96%AD&kt=1&wt=1&ky=1&wy=1&sk=partial&t=kotoba

    for t in $argv
        set url2 (
        ruby -r uri -e '
        ARGV.each{|c|puts URI.encode_www_form_component(c)}
        ' $t
        )
        curl --silent --location "$url1$url2$url3" |
        nkf -w -Lu |
        pandoc -f html -t plain 2>/dev/null |
        sed '
        1,/検索条件：「～を含む」/d;

        /^\[\]/d;

        /^絞り込む/,$d

        ' | uniq
    end
end
