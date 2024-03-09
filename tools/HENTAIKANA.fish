function GEN-HENTAIKANA
    set url https://cid.ninjal.ac.jp/kana/list/

    curl --silent --location $url |
    perl -Mutf8 -CSD -npe '
    # s/(<tr)/\n\n$1/g;
    # s%(</tr>)%$1\n\n%g;
    # s%(<[^</>]+>)%\n$1%g;
    s/(,)([{])/$1\n\n\n$2/g;
    s/,/,\n\t/g;
    s/([}],*)/\n\n$1/g;
    ' |
    rg -v -e :false -e :true -e '""' |
    rg -e '^$' -e '"note"' -e '"kana"' -e "jibo" -e "mj" -e '"ucs"' |
    tr -d '",' |
    awk -v RS= '/ucs:/ { $1=$1; print } ' |
    perl -Mutf8 -CSD -npe 's/(note:.*) (ucs:.*)/$2 $1/;' |
    ruby -ane '
        # # kana:あ jibo:安 mj:MJ090001 ucs:0x1b002
        # # kana:あ jibo:惡 mj:MJ090002 ucs:0x1b005 note:「を」の仮名としても使われる
        # # kana:え jibo:江 mj:MJ090014 ucs:0x1b001
        ucs = $F[3].gsub(/ucs:0x/, "")

        printf "\\\\変体仮名登録{%s}", ucs.hex.chr(Encoding::UTF_8)
        printf "{%s}", ucs
        printf "%%"
        printf " %s", $F[0]
        printf " %s", $F[1]
        printf " %s", $F[2]
        printf " %s", $F[3]
        printf " %s", $F[4]
        printf "\n"
    '
end
