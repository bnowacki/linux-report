#!/bin/bash

version="v1.0.0"

display_help() {
    echo "Usage: $0 [-v|h|H|d]"
    echo
    echo "Play the Tower of Hanoi game in your terminal!"
    echo "Program takes as an input height of the first tower and a directory in which the game will take place."
    echo
    echo "Options:"
    echo "  -H number   Height of the first tower, must satisfy the inequality: 1 < height < 10. 6 by default."
    echo "  -d string   Directory for temporary files, current directory by default."
    echo
    echo "  -v          Print the version of the program and exit."
    echo "  -h          Print this help and exit."
}

# Height of the first tower
height=6
# Directory for temporary files
dir="."

# Process command-line arguments
while getopts "H:d: :v :h" opt; do
    case $opt in
        v)
            echo $version
            exit
        ;;
        h)
            display_help
            exit
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
        \?)
            echo "Invalid option: -$OPTARG" >&2
            display_help
            exit 1
        ;;
    esac
done

# Recreate temp
rm -rf "${dir}/tower1"
rm -rf "${dir}/tower2"
rm -rf "${dir}/tower3"

mkdir "${dir}/tower1"
mkdir "${dir}/tower2"
mkdir "${dir}/tower3"

repeat(){
    for i in {1..90}; do echo -n "$1"; done
}

for ((i=height; i>0; i--))
do
    touch "${dir}/tower1/level${i}"
    printf ' %.0s' $(seq $((($height-$i)+1))) >> "${dir}/tower1/level${i}"
    printf '#%.0s' $(seq $(($i*2+1))) >> "${dir}/tower1/level${i}"
    printf '\n' >> "${dir}/tower1/level${i}"
    sleep 0.1
done

render() {
    
    for ((i=1; i<=height+1; i++))
    do
        echo "    |      |      |"
    done
    
    echo " ~~~~~~~~~~~~~~~~~~~~~~~ "
    echo "tower1: $(ls -txw0 "${dir}/tower1")"
    echo "tower2: $(ls -txw0 "${dir}/tower2")"
    echo "tower3: $(ls -txw0 "${dir}/tower3")"
}

render