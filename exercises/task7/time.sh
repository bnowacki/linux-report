#!/bin/bash

# Problem 2.7 Console clock
while true
do
    echo -ne "$(date +%T)\r" 
    sleep 1
done
