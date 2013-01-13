#!/bin/sh

NOW=`date '+%Y%m%d%H%M%S'`
NAME=screenshot-${NOW}
EXE='png'
SCRDIR=${HOME}/Downloads/
ONAME=${SCRDIR}${NAME}.${EXE}

if [ "$1" = "-s" ];then
    scrot -q 1 -bd 1 $ONAME 
elif [ "$1" = "-w" ];then
    delay=$(zenity --title="截图" --entry --text="设置延时(秒)："  --entry-text="1");
    if [ ! -z $delay ];then
        scrot -q 1 -bsd $delay $ONAME 
    else
        exit
    fi
fi

echo $ONAME | xsel -i
echo $ONAME | xsel -i -b
notify-send -t 5000 -i gtk-dialog-info "Success" $ONAME
