function Z
    set sdir (pwd | perl -Mutf8 -CSD -npe 's%(SORA-UTSU-NAMI)/.*%$1/source%')
    git checkout $src

    rg --glob '*.tex' --sort path -C 2 -e "$argv[1]" $sdir
end

function ZZ
    set src (pwd | perl -Mutf8 -CSD -npe 's%(SORA-UTSU-NAMI)/.*%$1/source%')

    set tt (rg -l --glob '*.tex' --sort path -e "$argv[1]" $src)

    for t in $tt
        perl -Mutf8 -CSD -npe "s/$argv[1]/$argv[2]/g" $t | diff -u $t -
    end
end

function ZZZ
    set src (pwd | perl -Mutf8 -CSD -npe 's%(SORA-UTSU-NAMI)/.*%$1/source%')
    git checkout $src
    set tt (rg -l --glob '*.tex' --sort path -e "$argv[1]" $src)

    for t in $tt
    perl -Mutf8 -CSD -i -npe "s/$argv[1]/$argv[2]/g" $t
    end
    git diff $tt

    echo
    echo "[fix] $argv[3]"  | tee    COMMITLOG
    echo                   | tee -a COMMITLOG
    echo "perl -Mutf8 -CSD -i -npe \"s/$argv[1]/$argv[2]/g\"" | tee -a COMMITLOG
end

function ZZZZ
    if [ -f COMMITLOG ]
        set src (pwd | perl -Mutf8 -CSD -npe 's%(SORA-UTSU-NAMI)/.*%$1/source%')
        git commit --file COMMITLOG $src
        rm COMMITLOG
        git show
    end
end
