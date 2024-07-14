#!/usr/bin/env bash

set -x

GCC=$(which gcc)
echo $GCC
if [ -z "$GCC" ] ; then
    echo may be you need install xcode
    exit 255
fi

{
    HOMEBREW_PREFIX=$(brew --prefix)

    # luarocks 以下をユーザ権限領域に変更
    # t="$HOMEBREW_PREFIX/Cellar/luarocks"
    # [ -d "$t" ] && sudo chown -R $USER $t

    brew uninstall luarocks || sudo rm -rf /opt/homebrew/Cellar/luarocks/
    brew uninstall lua      || brew uninstall --ignore-dependencies lua

    CHK_DIR=$(
        echo $HOMEBREW_PREFIX/etc/luarocks
        echo $HOMEBREW_PREFIX/lib/lua
        echo $HOMEBREW_PREFIX/lib/luarocks
        echo $HOMEBREW_PREFIX/share/lua
           )

    for t in $CHK_DIR ; do
        if [ -d "$t" ] ; then
            rm -rf "$t" || sudo rm -rf "$t"
        fi
    done

    brew reinstall lua
    brew reinstall luarocks

    # luarocks が HOMEBREW_PREFIX 以下に書き込めるか不安なので
    # 失敗したら sudo 付きで再試行してみる
    luarocks install luasocket || sudo luarocks install luasocket

    find $CHK_DIR
    which -a lua luarocks

    t=$HOMEBREW_PREFIX/share/lua
    ls -l $t
}
