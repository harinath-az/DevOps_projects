#!/bin/bash
# Ensure the script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo."
    exit 1
fi

if [ $# -gt 0 ]; then
    for USER in "$@"; do
        echo "Processing user: $USER"

        # Checking if the user already exists, if not adding the user

        if [[ $USER =~ ^[a-zA-Z0-9_-]+$ ]]; then
            if id "$USER" &>/dev/null; then
                echo "User named $USER already exists, try another username"
            else
                echo "Creating new user..."
                if sudo useradd -m "$USER" --shell /bin/bash; then
                    echo "User $USER added successfully"

                    # Generate temporary password
                    SPECIAL_CHARACTER=$(echo '!@#$%^&*()_' | fold -w1 | shuf | head -1)
                    PSWRD="Atlasian@${RANDOM}${SPECIAL_CHARACTER}"
                    if echo "$USER:$PSWRD" | sudo chpasswd; then
                        echo "Password set successfully"
                        echo "The user $USER's temporary password is $PSWRD"
                        echo "User $USER must change their password at first login."

                        # Force password change
                        sudo passwd -e "$USER"

                        # Log user and password securely
                        echo "$(date '+%Y-%m-%d %H:%M:%S') - $USER - $PASSWORD" >>/var/log/user_creation.log
                        sudo chmod 600 /var/log/user_creation.log
                    else
                        echo "Failed to set the password for $USER."
                        exit 1
                    fi

                else
                    echo "Failed to add user $USER, please check the permissions or try again with a different username"
                fi
            fi

        else
            echo "Invalid username: $USER. Use only letters, numbers, underscores, or hyphens."
        fi
    done
else
    echo "No users provided. Please provide atleast one username."
    exit 1
fi
