#!/bin/bash

function change(){
    WINEPREFIX=$HOME/.wineprefixes/$1 WINEDLLOVERRIDES="winemenubuilder.exe=n,d" WINEARCH=win32 ${@:2}
}

function run(){
    declare -A dict
    dict[bigfishgames]="$HOME/.wineprefixes/bigfishgames/drive_c/Program Files/bfgclient/bfgclient.exe"

    if [ ${dict[$1]+1} ]; then
        WINEPREFIX=$HOME/.wineprefixes/$1 WINEDLLOVERRIDES="winemenubuilder.exe=n,d" WINEARCH=win32 wine "${dict[$1]}"
    else
        echo "Key not exist"
    fi
}

$@
