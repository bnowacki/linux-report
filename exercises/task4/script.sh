#!/bin/bash

# Problem 2.4 Mr. Proper - cleaning backup and core files
find ~/ -type f \( -name 'core' -o -name '*~' \) -delete
