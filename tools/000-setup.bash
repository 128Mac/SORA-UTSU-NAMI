#!/usr/bin/env bash

[ -d "Build" ] || mkdir Build 
(
    cd Build
    for url in \
    	https://raw.githubusercontent.com/zr-tex8r/BXglyphwiki/master/bxglyphwiki.sty \
    	https://ctan.org/macros/latex209/contrib/misc/indent.sty \
    	http://xymtex.com/fujitas2/texlatex/tateyoko/jdkintou.sty \
    	http://xymtex.com/fujitas2/texlatex/tategumi/sfkanbun.sty \
    	http://xymtex.com/fujitas2/texlatex/tategumi/warichu.sty \
        ; do
            curl --silent --location -O $url
            nkf --overwrite -Lu -w $(basename $url)
        done
)
[ -d "Build/BXglyphwiki" ] || mkdir Build/BXglyphwiki 
(
    cd Build/BXglyphwiki 
    url=https://raw.githubusercontent.com/zr-tex8r/BXglyphwiki/master/bxglyphwiki.lua
    curl --silent --location -O $url
    sed -e '1s/^-*//' $(basename $url) > $(basename $url .lua)
    chmod +x $(basename $url .lua)
    echo add $(pwd) to PATH
)
