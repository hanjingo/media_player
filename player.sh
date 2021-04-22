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
fpid="run.pid"
curr_file=""
curr_key=1
do_single_loop=0
do_background_play=1

# remove pid file
doRmPid(){
    if [ -f $fpid ]; then
        rm $fpid
    fi
}

# kill current proccgress
doKillPid(){
    if [ -f $fpid ]; then
        pid=$(cat $fpid)
        echo "kill pid:$pid"
        kill $pid
        doRmPid
    fi
}

# play file
doPlay(){
    tfile="$dir/${file_map[$curr_key]}"
    if [ -f !$tfile ]; then
        echo "file not exist"
        return
    fi

    curr_file="$dir/${file_map[$curr_key]}"

    if [ $do_background_play==1 ];then
        echo "play background file:$curr_file"
        doRmPid
        nohup ffplay -autoexit -nodisp "$curr_file" > /dev/null 2>&1 & echo $! > $fpid
    else
        echo "play file:$curr_file"
        ffplay -autoexit "$curr_file"
    fi
}

# clean tmp file
doClean(){
    doRmPid
}

# clear screen
doCls(){
    printf "\033c"
}

# list file
doListFile(){
    for key in ${!file_map[*]}
    do
        echo "$key.${file_map[$key]}"
    done
}

# inc index
doIncKey(){
    if [ $curr_key -ge ${#file_map[@]} ]; then
        let curr_key=1
        echo "set curr key=$curr_key"
    else
        if [ -f "$dir/${file_map[$curr_key+1]}" ]; then
            let curr_key++
            echo "set curr key=$curr_key"
        fi
    fi
}

# dec index
doDecKey(){
    if [ $curr_key -le 1 ]; then
        let curr_key=${#file_map[@]}
        echo "set curr key=$curr_key"
    else
        if [ -f "$dir/${file_map[$curr_key-1]}" ]; then
            let curr_key--
            echo "set curr key=$curr_key"
        fi
    fi
}

# loop read
while read -p "Cmd (q:quit, k:end play, l:open single loop, n:next, p:prev, f:flush screan ...):" cmd
do 
    case $cmd in 
        "q")
            doKillPid
            doClean
            break
        ;;
        "l")
            do_single_loop=1
            echo "single loop enabled"
            continue
        ;;
        "nl")
            do_single_loop=0
            echo "single loop disenable"
            continue
        ;;
        "k")
            doKillPid
            doCls
            doListFile
        ;;
        "n")
            doKillPid
            doIncKey
            doPlay
        ;;
        "p")
            doKillPid
            doDecKey
            doPlay
        ;;
        "f")
            doCls
            doListFile
        ;;
        *)
            if [ -n "`echo $cmd | sed 's/[0-9]//g'`" ]; then
                echo "please input valid num!!!"
                continue
            fi
            let curr_key=$cmd
            doPlay
        ;;
    esac
done