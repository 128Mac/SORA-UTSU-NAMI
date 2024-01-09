#!/usr/bin bash


rg --glob '*.tex' --sort path 'ruby.g.' source |
    rg -v -e 々々 -e 換字 |
    tr ':' '\t' |
    ruby -an tools/062-ruby-mono-change.rb |
    while read file kanji old new ; do
        # echo "$file / $kanji / $old / $new"
        #git checkout $file
        #echo  "gsub(/\[g\]([{]$kanji[}])[{]$old[}]/, '\1{$new})'"
        git checkout .
        ruby -pn -i -e "
        \$_.gsub!(/ruby.g.[{]($kanji)[}][{]$old[}]/, 'ruby{$kanji}{$new}')
        " $file

        (
            echo "[fix] ルビ調整「" $kanji "」"
            echo
            echo "   「" $old "」→「" $new "」"
        ) > COMMITLOG

        git commit --file COMMITLOG $file
        rm COMMITLOG
    done |
    cat ; exit

exit
