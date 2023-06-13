#!/bin/bash

day_of_week=$(date +%u)
hour=$(date +%H)
# day_of_week=3
# hour=14

# List of all students
# File format:
# <user name> : <day of the week> : <from hour> : <to hour>
students_file="students"

# List of attendances
# File format of class register:
# <user name> : <day of the week> : <from hour> : <to hour> : <tty> : <date>
class_register="class-register"

# used to track already marked attendances,
# instead of checking every line in class register we only need to check attendances added today
# File format of class register:
# <user name> : <day of the week> : <from hour> : <to hour> : <tty> : <date>
tmp_class_register="tmp-class-register"

# clear temp class register if the date changed
last_date_in_tmp_file="$(tail -n 1 $tmp_class_register | awk -F" : " '{ print $NF }')"
if [ "$last_date_in_tmp_file" != "$(date +%D)" ]; then
  echo -n '' >$tmp_class_register
fi

# list users that should have logged in during the last hour
students="$(awk -F" : " "
  (\$2 == $day_of_week) && (\$3 < $hour) && (\$3 > $hour - 1) { print \$0 }
" $students_file)"

# list all users that have actually logged in during the last hour
last_logged=$(last -s -1hour | head -n -2 | awk '{ print $1":"$2 }')

# loop through all students that should have their attendance checked
echo "$students" | while read student_line; do
  student=$(echo "$student_line" | awk -F" : " '{ print $1 }')

  # loop through all students that actually logged in during the last hour
  echo "$last_logged" | while read log_line; do
    user=$(echo "$log_line" | awk -F":" '{ print $1 }')
    tty=$(echo "$log_line" | awk -F":" '{ print $2 }')

    if [ "$student" = "$user" ]; then
      line_in_register="$(
        echo "$student_line" |
          awk "
            BEGIN { 
              FS=\" : \" 
              OFS=\" : \" 
            }
            { print \$1, \$2, \$3, \$4, \"$tty\", \"$(date +%D)\" }
          "
      )"

      # if student already has marked attendance for current date break the loop
      if grep -q "$line_in_register" "$tmp_class_register"; then
        break
      fi
      # register student's attendance
      echo "$line_in_register" >>$tmp_class_register
      echo "$line_in_register" >>$class_register
      break
    fi
  done
done
