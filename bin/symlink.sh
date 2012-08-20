#!/bin/bash

function mksymlink() {
    #find all files
    files=(`find -L $1 -mindepth 1 -maxdepth 1 ! -name "$3"`)

    for file in ${files[*]}; do
        #strip file name
        file=${file##*/}

        #remove exsiting file
        if [ ! -h $2/$file ];then
            rm -rf $2/$file
        fi

        #make symbol link
        ln -sf $1/$file $2/
    done
}

#public 
mksymlink $HOME/Dropbox $HOME "[^P]*"

#home
mksymlink $HOME/Dropbox/home $HOME ""

#config
mksymlink $HOME/config $HOME ".config"
mksymlink $HOME/config/.config $HOME/.config ""
