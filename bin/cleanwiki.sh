#!/bin/bash
insdir=/home/lainme/web/notebook/data 
mtime=5

#删除超过$mtime天的修订记录
find "$insdir"/attic/ -type f -mtime +$mtime -print0 | xargs -0r rm -f

#删除超过$mtime的缓存
find "$insdir"/cache/?/ -type f -mtime +$mtime -print0 | xargs -0r rm -f

#删除超过一天的锁定文件
find "$insdir"/locks/ -name '*.lock' -type f -mtime +1 -print0 | xargs -0r rm -f
 
#删除已不存在的文件的meta
metalist=`find $insdir/meta/ -mindepth 2 -type f`
for metafile in $metalist;do
    pagefile=$insdir/pages/${metafile#$insdir/meta/}
    pagefile=${pagefile%.*}.txt

    if [[ ! -a $pagefile ]];then
        rm $metafile
    fi
done

#删除空目录
find "$insdir"/pages/ -type d -empty -delete
find "$insdir"/media/ -type d -empty -delete
find "$insdir"/meta/  -type d -empty -delete
find "$insdir"/tmp/   -type d -empty -delete
