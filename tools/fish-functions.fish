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
        set url https://0g0.org/unicode/$cp/
        [ -f "$html" ] || curl --silent --location -o $html $url
        [ -f "$html" ] || continue
        echo
        pandoc -f html -t org $html |
              rg -v -e '^:'\
                    -e 文字をクリップボードにコピー \
                    -e 'https://' \
                    -e 一覧とURLエンコード検索・変換サイト \
                    -e このサイトについて \
                    -e お問い合わせフォーム \
                    -e '^__' \
                    -e '0g0.org' |
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
