#!/bin/sh

last_dir=/Volumes/DATA/store/music
dir=$(pwd)

while read -p "Enter media abs path:" dir
do
    if [ $dir=="\n" ];then
        echo "input empty dir, use last input dir:$last_dir"
        dir=$last_dir
    fi

    if [ -f !$dir ];then
        echo -n "dir:$dir not exist, please input again!!!"
        continue
    fi
    break
done

declare -a file_map=()

# list the file of dir
files=$(ls $dir|tr " " "\?")
i=0
for file in $files
do
    let i++
    file_map[i]=`tr "\?" " " <<<$file`
done

for key in ${!file_map[*]}
do
    echo "$key.${file_map[$key]}"
done

# reading user input
while read -p "Enter the index to play:" idx
do 
    case $idx in 
        "q")
            break
        ;;
        "Q")
            break
        ;;
    esac

    abs_file_path="$dir/${file_map[$idx]}"
    echo "play file:$abs_file_path"
    ffplay "$abs_file_path"
done