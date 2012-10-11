#!/bin/bash
#blogtng maintance script

#--------------------------------------------------
#help
#--------------------------------------------------
function show_help(){
    echo "Usage: pagemove.sh -d DATADIR -p  "
    echo "Description: blogtng maintance script for moving blog page and delete non-existing page from database"
    echo "Usage: pagemove.sh [options]"
    echo "-d DATADIR    - Reuired. Dokuwiki data directory"
    echo "-p PATTERN    - Optional. Sed pattern for page move. Default is empty, no page move"
    echo "-v VERSION    - Optional. Sqlite version, 2 or 3. Default is 3"
    echo "-t            - Optional. Dry run, do not make changes"
    echo "-h            - show this help"
}

#--------------------------------------------------
#parse command line arguments
#--------------------------------------------------
if [ $# -eq 0 ];then
    show_help
    exit
fi

datadir=""
pattern=""
version=3
dryruns=0

while [ $# -gt 1 ];do
    case $1 in
        -d) datadir=$2;shift 2;;
        -p) pattern=$2;shift 2;;
        -v) version=$2;shift 2;;
        -t) dryruns=1;shift 1;;
        -h) show_help;shift 1;;
        *) echo "option $1 not recognizable, type -h to see help list";exit;;
    esac
done

if [ ! -d $datadir ];then
    echo "$datadir is not a directory"
    exit
fi

if [ "$version" == "2" ];then
    sqlite_cmd=sqlite
    sqlite_dbn=$datadir/meta/blogtng.sqlite
elif [ "$version" == "3" ];then
    sqlite_cmd=sqlite3
    sqlite_dbn=$datadir/meta/blogtng.sqlite3
else
    echo "Sqlite version should be 2 or 3"
    exit
fi

#--------------------------------------------------
#pagemove
#--------------------------------------------------
for old_page in $($sqlite_cmd $sqlite_dbn "select page from entries");do
    #new page
    new_page=`echo $old_page | sed "$pattern"`
  
    #old and new file name
    old_fn=$datadir/pages/`echo $old_page | sed "s/:/\//g"`.txt
    new_fn=$datadir/pages/`echo $new_page | sed "s/:/\//g"`.txt

    #old and new md5
    old_md5=$(php -r "print(md5('$old_page'));")
    new_md5=$(php -r "print(md5('$new_page'));")

    #------------------------------------------------
    #delete non existing page
    #------------------------------------------------
    if [ ! -f $old_fn ];then
        echo -e "\e[00;31m[DELETE]\e[00m $old_page"
        if [ "$dryruns" == "0" ];then
            $sqlite_cmd $sqlite_dbn "delete from entries where pid='$old_md5'"
        fi
        continue
    fi

    #------------------------------------------------
    #rename page
    #------------------------------------------------
    if [ "$old_fn" != "$new_fn" ];then
        echo -e "\e[00;34m[RENAME]\e[00m $old_page \e[00;34m[TO]\e[00m $new_page"
        if [ "$dryruns" == "0" ];then
            #rename filename
            mkdir -p `dirname $new_fn`
            mv $old_fn $new_fn
            #rename pagename
            $sqlite_cmd $sqlite_dbn "update entries set pid='$new_md5',page='$new_page' where pid='$old_md5'"
            $sqlite_cmd $sqlite_dbn "update comments set pid='$new_md5' where pid='$old_md5'"
            $sqlite_cmd $sqlite_dbn "update tags set pid='$new_md5' where pid='$old_md5'"
            $sqlite_cmd $sqlite_dbn "update subscriptions set pid='$new_md5' where pid='$old_md5'"
        fi
    fi
done
