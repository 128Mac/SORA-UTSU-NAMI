#!/usr/bin/env fish

function CONVERT
    set infile $argv[1]
    set otfile ( basename $infile )

    cat $infile |
    nkf -Lu -w |
    perl -Mutf8 -CSD       -npe 's/(。)/$1\n/g;            # 読点で改行           ' |
    perl -Mutf8 -CSD       -npe 's/^[[:blank:]]+$//;       # 空行を調整           ' |
    perl -Mutf8 -CSD       -npe 'BEGIN{ my $willdel = 0 }  # コメントアウトされた不要部分の削除
                                 $willdel = 999999 if /%\\\\begin{tblr}/ ;
                                 $willdel =      1 if /%\\\\end{tblr}/   ;
                                 s/^%.*\n// if $willdel > 0;
                                 $willdell = $willdell - 1;
                                                                                  ' |
    perl -Mutf8 -CSD -0777 -npe 's/\n\n+/\n\n/g;           # 連続する改行を一つに ' |
    perl -Mutf8 -CSD       -npe 's/(.)(\\\\ruby)/$1\n$2/g; # \ruby 単位に改行     ' |
    perl -Mutf8 -CSD       -npe '
                                 s/( う つ)[[:blank:]]*$/$1 %空白有り/;

                                 s/([\\\\]*　+)$/$1%全角空白/;
                                 s/(\\\\[[:blank:]]+)$/$1%空白有り/;
                                 s/[ \t]+$//;
                                ' > "$otfile" # | /usr/bin/diff -u $otfile - #
end

if test -z "$argv"
    set argv ../露伴『天うつ浪』春陽堂版全
end
echo $argv

set targets (
    for arg in $argv
       find $arg -iname '*.tex'
    end |
    sort -u
)

for target in $targets
    CONVERT $target
end
