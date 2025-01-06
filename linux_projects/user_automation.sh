#!/bin/bash
# Checking if the user already exists, if not adding the user
if [ $# -gt 0 ]; then
    USER=$1
    echo "Checking for user: $USER"
    if id "$USER" $ >/dev/null; then
        echo "User named "$USER" already exists, try another username"
    else
        echo "Adding new user..."
        if sudo useradd -m "$USER" --shell /bin/bash; then
            echo "User "$USER" added successfully"

            # Generate temporary password
            SPECIAL_CHARACTER=$(echo '!@#$%^&*()_' | fold -w1 | shuf | head -1)
            PSWRD="Atlasian@${RANDOM}${SPECIAL_CHARACTER}"
            if echo "$USER":"$PSWRD" | sudo chpswd; then
                echo "Password set successfully"
                echo "The user "$USER"'s temporary password is ${PSWRD}"

                # Force password change
                sudo passwd -e "$USER"
            else
                echo "Failed to set the password for $USER."
                exit 1
            fi

        else
            echo "Failed to add user, please check the permissions or try again with different username"
        fi
    fi

else
    echo "enter valid parameter"
fi
