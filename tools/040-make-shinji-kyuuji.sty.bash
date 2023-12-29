t=tools/030-pickup-kanji-char.txt

cat $t |
    ruby -ane '
    oo = $F[0];
    oc = ""

    if ( oo =~ /^[^\p{han}]+$/ )
       oo = "\\GWI{" + oo +  "}"
    else
       oc = " 表示[u" + oo.encode( "UTF-8" ).ord.to_s(16) + "]"
    end

    nn = $F[2].gsub(/[()]/, "");
    nc = " 基準[u" + nn.encode( "UTF-8" ).ord.to_s(16) + "]"

    unless ( nn == oo)
       printf "\\基準文字と表示文字変換{%s}{%s}", nn, oo
       printf "%%%s%s\n", nc, oc
    end
'
