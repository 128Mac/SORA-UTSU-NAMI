download_src=from-mr2h-src
[ -d $download_src ] && find  $download_src -delete
[ -d $download_src ] || mkdir $download_src
git -C $download_src init

download_dir=from-mr2h-露伴『天うつ浪』春陽堂版全
[ -d "$download_dir" ] || mkdir $download_dir
[ -d "$download_dir" ] || exit
pushd $download_dir

function CURL() {
    url=$2
    out=$1-$(basename $url)
    [ -f "$out" ] || curl --silent --location --output $out $url
}
function UNAR() {
    out=$1
    zip=$(find . -iname $out-$(basename $2))
    if [ -f "$zip" ] ; then
        if [ ! -d "$out" ] ; then
            unar -quiet -output-directory $out $zip
            find $out '(' -iname 'bxgw_*' -o -iname '*.aux' -o -iname '*.log' -o -iname '*.synctex.gz' ')' -delete
        fi
    fi
}
function COPY() {
    dir=$1
    zip=$2
    (
        if [ -d "$dir" ] ; then
            find "$dir" -type f -iname '*.tex' -o -iname '*.pdf'
        fi
    ) |
        sort |
        while read src ; do
            dst=$(
                basename $src |
                    perl -Mutf8 -CSD -npe '
                        s/(天うつ浪第一)/vol-1-$1/;
                        s/(天うつ浪第二)/vol-2-$1/;
                        s/(天うつ浪第三)/vol-3-$1/;
                    '
               )
            cp -p $src ../$download_src/$dst
            chmod -x   ../$download_src/$dst
        done
   git -C ../$download_src/ add .
   git -C ../$download_src/ commit -am "from mr2h $dir $zip"
}


URL=https://okumuralab.org/tex/pluginfile.php/6/mod_forum/attachment/22904/露伴『天うつ浪』春陽堂版全.zip
CURL 2023-12-10 $URL
UNAR 2023-12-10 $URL
COPY 2023-12-10 $URL

URL=https://okumuralab.org/tex/pluginfile.php/6/mod_forum/attachment/22909/092-3-01-其一.tex
CURL 2023-12-12 $URL
[ -d 2023-12-12 ] || mkdir 2023-12-12
mv 2023-12-12-$(basename $URL) 2023-12-12/$(basename $URL)
COPY 2023-12-12 $URL

echo FROM mail mv ~/Downloads/天うつ浪第三.zip 2023-12-14-天うつ浪第三.zip
UNAR 2023-12-14 天うつ浪第三.zip
COPY 2023-12-14 天うつ浪第三.zip

