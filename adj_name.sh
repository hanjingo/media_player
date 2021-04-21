#!/bin/sh

dir=""
while read -p "Enter media abs path:" dir
do
    if [ -f !$dir ];then
        echo -n "dir:$dir not exist, please input again!!!"
        continue
    fi
    break
done

files=$(ls $dir|tr " " "\?")
#files=$(ls $dir)
do_ask="y"
for file in $files
do
    #new_file=`tr "\?" "" <<<$file`
    new_file=$(echo $file | sed 's/?//g')
    file=`tr "\?" " " <<<$file`
    if [ $do_ask == "y" ];then
        read -p "rename:$file->$new_file (y:yes, n:no, q:quit ya:yes to all, na:no to all)?" cmd
        case $cmd in
            "n")
                continue
            ;;
            "N")
                continue
            ;;
            "q")
                break
            ;;
            "Q")
                break
            ;;
            "ya")
                do_ask="n"
            ;;
            "na")
                break
            ;;
        esac
    fi

    echo -n "moved $dir/$file->$dir/$new_file"
    mv "$dir/$file" "$dir/$new_file"
    # echo $file
done