function XX
    set src ( pwd | perl -Mutf8 -CSD -npe 's%(SORA-UTSU-NAMI).*%$1/source%;' )

    git checkout $src

    set p1 "\\\\ruby[^{]*"
    set p2 ( echo $argv[1] | perl -Mutf8 -CSD -npe 's/([{|}])/\\\\$1/g' )
    set p3 '[^}]+'
    set p4 ( echo $argv[2] | perl -Mutf8 -CSD -npe 's/([{|}])/\\\\$1/g' )
    set pp "($p1)\{($p2)($p3)\}\{($p4)\|"
    set qq '\1{\2}{\4}\n\1{\3}'

    echo DEBUG rg  --glob '[0-9]*.tex' --sort path -e "$pp" $src

    set tt ( rg -l --glob '[0-9]*.tex' --sort path -e "$pp" $src)

    for t in $tt
        perl -Mutf8 -CSD -npe "s/$pp/\\1\{\\2\}\{\\4\}\n\\1\{\\3\}\{/; " $t | diff -u $t -
    end
end

function XXX
    set src ( pwd | perl -Mutf8 -CSD -npe 's%(SORA-UTSU-NAMI).*%$1/source%;' )

    git checkout $src

    set p1 "\\\\ruby[^{]*"
    set p2 ( echo $argv[1] | perl -Mutf8 -CSD -npe 's/([{|}])/\\\\$1/g' )
    set p3 '[^}]+'
    set p4 ( echo $argv[2] | perl -Mutf8 -CSD -npe 's/([{|}])/\\\\$1/g' )
    set pp "($p1)\{($p2)($p3)\}\{($p4)\|"
    set qq '\1{\2}{\4}\n\1{\3}'

    set tt ( rg -l --glob '[0-9]*.tex' --sort path -e "$pp" $src)

    for t in $tt
        perl -Mutf8 -CSD -i -npe "s/$pp/\\1\{\\2\}\{\\4\}\n\\1\{\\3\}\{/; " $t
    end

    git diff $tt

    echo
    echo "[fix] 親文字列 「$argv[1]（$argv[2]）」 で分割" | tee    COMMITLOG
    
end

function XXXX
    if [ -f COMMITLOG ]
        set src (pwd | perl -Mutf8 -CSD -npe 's%(SORA-UTSU-NAMI)/.*%$1/source%')
        git commit --file COMMITLOG $src
        rm COMMITLOG
        git show
    end
end
