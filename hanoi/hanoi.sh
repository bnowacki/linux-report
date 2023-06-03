#!/bin/bash

version="v1.0.0"

display_help() {
    echo "Usage: $0 [-v|h|H|d|s]"
    echo
    echo "Play the Tower of Hanoi game in your terminal!"
    echo "Program takes as an input height of the first tower and a directory in which the game will take place."
    echo
    echo "Options:"
    echo "  -H number   Height of the first tower, must satisfy the inequality: 1 < height < 10. 6 by default."
    echo "  -d string   Directory for temporary files, current directory by default."
    echo "  -s          Spectator mode."
    echo
    echo "  -v          Print the version of the program and exit."
    echo "  -h          Print this help and exit."
}

# Height of the first tower
height=6
# Directory for temporary files
dir="."
# Other users can spectate the game
spectator=false

# Process command-line arguments
while getopts "H: d: :v :h :s" opt; do
    case $opt in
        v)
            echo $version
            exit
        ;;
        h)
            display_help
            exit
        ;;
        s)
            spectator=true
        ;;
        H)
            # Check if the input is between 1 and 10
            if ! [[ $OPTARG =~ ^[2-9]$ ]]; then
                echo "The given height $OPTARG does not satisfy the inequality 1 < height < 10."
                exit
            fi
            height=$OPTARG
        ;;
        d) dir=$OPTARG;;
        # catch invalid options
        \?)
            echo "Invalid option: -$OPTARG" >&2
            display_help
            exit 1
        ;;
    esac
done

# count height of the tower if in spectator mode
if [ "$spectator" = true ]; then
    height=$(find ${dir}/tower1 ${dir}/tower2 ${dir}/tower3 -type f | wc -l)
fi

# Recreate temp files if in player mode
if [ "$spectator" = false ]; then
    rm -rf "${dir}/tower1" "${dir}/tower2" "${dir}/tower3"
    mkdir "${dir}/tower1" "${dir}/tower2" "${dir}/tower3"
    
    # generate level files for tower1
    for ((i=height; i>0; i--))
    do
        touch "${dir}/tower1/level${i}"
        sleep 0.1 # sleep to ensure files have proper creation times, bcs we use it to determine disk order
    done
fi

# empty_pole is a | padded with spaces on both sides
empty_pole="$(printf ' %.0s' $(seq $(($height)))) | $(printf ' %.0s' $(seq $(($height))))"

# Generate disks from #'s
gen_disk(){
    local size="${1: -1}" #last char of level file name is disk size
    local disk=$(printf ' %.0s' $(seq $(($height-$size+1)))) # padding left
    local disk="${disk}$(printf '#%.0s' $(seq $(($size*2+1))))" # hashtags
    local disk="${disk}$(printf ' %.0s' $(seq $(($height-$size+1))))" # padding right
    printf "$disk"
}

# render game view
render() {
    # get level files as arrays
    # should be a 2d array, but they aren't well implemented in bash
    tower1_files=($(ls -tx "${dir}/tower1"))
    tower2_files=($(ls -tx "${dir}/tower2"))
    tower3_files=($(ls -tx "${dir}/tower3"))
    
    towers="${empty_pole}${empty_pole}${empty_pole}\n"
    # generate tower from top to bottom
    for ((i=height; i>0; i--))
    do
        # 1st tower
        disk=$empty_pole
        if [ ${#tower1_files[*]} -ge $i ]; then
            disk=$(gen_disk ${tower1_files[-$i]})
        fi
        towers="${towers}${disk}"
        
        # 2nd tower
        disk=$empty_pole
        if [ ${#tower2_files[*]} -ge $i ]; then
            disk=$(gen_disk ${tower2_files[-$i]})
        fi
        towers="${towers}${disk}"
        
        # 3rd tower
        disk=$empty_pole
        if [ ${#tower3_files[*]} -ge $i ]; then
            disk=$(gen_disk ${tower3_files[-$i]})
        fi
        towers="${towers}${disk}"
        
        towers="${towers}\n"
    done
    
    printf "$towers"
    printf '~%.0s' $(seq $((($height*2+3)*3)))
    echo
    echo "tower1: ${tower1_files[*]}"
    echo "tower2: ${tower2_files[*]}"
    echo "tower3: ${tower3_files[*]}"
}

# main game loop
while true
do
    clear
    render
    
    # just refresh screen for spectators
    if [ "$spectator" = true ]; then
        sleep 0.5
        continue
    fi
    
    #  get valid input from user
    read from to
    if ! ([[ $from =~ ^[1-3]$ ]] && [[ $to =~ ^[1-3]$ ]]); then
        echo "Invalid move, to move a disk type:"
        echo "from_tower_number dest_tower_number"
        sleep 1
        continue
    fi
    
    # -t            sort by modification time
    # -x            list entries by lines instead of by columns
    # awk -F" " ... separate input by spaces and print the first entry
    level=$(ls -tx "${dir}/tower${from}" | awk -F" " '{ print $1 }')
    # top disk on the destination tower has to be larger than the top disk in source tower
    top_in_dest=$(ls -tx "${dir}/tower${to}" | awk -F" " '{ print $1 }')
    
    # if no level file found or top disk in dest exists and is smaller than source disk
    if [ -z $level ] || ([ -n $top_in_dest ] && [ ${level: -1} -gt ${top_in_dest: -1} ]); then
        echo "Invalid move"
        sleep 1
        continue
    fi
    
    file="${dir}/tower${from}/${level}"
    dest="${dir}/tower${to}/${level}"
    
    # move disks
    mv $file $dest
    touch $dest # mv doesn't refresh file's modification time, therefore we touch it!
done
