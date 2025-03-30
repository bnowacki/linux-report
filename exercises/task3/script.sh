#!/bin/bash

# Who am I and where am I?
echo "username: $(id -un)
main group: $(id -gn)
all groups: $(id -Gn)
hostname: $(uname -n)
current directory: $(pwd)"

