#!/bin/bash
# Checking if users already exist and adding them if they don't
if [ $# -gt 0]; then
    USER=$1
    echo $USER
    EXISTING_USER=$(cat /etc/passwd | grep -i -w $USER | cut -d ":" -f1)
    if ['${USER}'=$'{EXISTING_USER}']; then
        echo "user exists, please enter another user name"
    else
        echo "adding new user"
        sudo useradd -m --shell /bin/bash
    fi

else
    echo "Please enter a valid parameter"
fi
