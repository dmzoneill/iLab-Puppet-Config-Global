#!/bin/bash

(cd /etc/puppet/; git pull)

src='/etc/puppet/environments'
IFS=$'\n'
 
for dir1 in `ls "$src/"`; do
    if [ -d "$src/$dir1" ]; then
        for dir2 in `ls "$src/$dir1"`; do
            if [ -d "$src/$dir1/$dir2/.git" ]; then
                echo $src/$dir1/$dir2
                (cd $src/$dir1/$dir2/; git pull)
            fi
        done
    fi
done
