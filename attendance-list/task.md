# Exercise 5.1 Automatic attendance list

## Create a program that checks attendance on operating systems laboratory.

Program will make use of `last` command and three additional files:

- Students list - informs about day and hour of classes of every laboratory group. Format:

```
<user name> : <day of the week> : <from hour> : <to hour>
```

- Class register - contains attendance lists from whole semester. Format:

```
<user name> : <day of the week> : <from hour> : <to hour> : <tty> : <date>
```

- Temporary class register. Format: same as class register.

Assume that program will be run every hour. In each run it will read students lists, what users should have logged in during previous hour and if they have actually logged in (command `last`). If the user has logged in, he will be marked in the class register (hours "from-to" should be copied from student's list, not from output of `last` command).
Attendance for each user should not repeat for one class (classes last two hours, while the program is run every hour). This may make usage of temporary class register necessary.
