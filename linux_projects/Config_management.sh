#User when enters username to create user, this function checks if user already exists and prompts to enter a newuser name. If username is unique it creates user
#and assigns a temporary password and forces user to change password on first login.
add_user () {
    # Ensure the script is run with sudo
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root. Use sudo."
        exit 1
    fi
    
    if [ $# -gt 0 ]; then
        local $USER
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
                        
                        # Add user to necessary groups
                        sudo usermod -aG sudo,users "$USER"
                        
                        # Set ownership and permissions for home directory
                        sudo chown "$USER:$USER" "/home/$USER"
                        sudo chmod 700 "/home/$USER"
                        
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
        
    else
        echo "No users provided. Please provide atleast one username."
        exit 1
    fi
    
}


#This function installs packages based on the package manager
install_packages () {
    echo "Installing packages..."
    local PACKAGES=("git" "curl" "vim" "htop" "nginx")
    if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y "${PACKAGES[@]}"
        elif command -v yum &>/dev/null; then
        sudo yum install -y "${PACKAGES[@]}"
    else
        echo "Unsupported package manager."
    fi
}

configure_firewall () {
    echo "This function provides basic security to the users by configuring basic firewall rules"
    echo "Configuring firewall..."
    if command -v ufw &>/dev/null; then
        sudo ufw allow 22/tcp
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        sudo ufw enable
        echo "Firewall configured successfully."
    else
        echo "Firewall tool not found (e.g., ufw)."
    fi
    
}

#Display help function which gives instructions to user when user doesn't know how to run the script
display_help()
{
    echo "The Below instructions help you on how to run the script"
    echo "Usage: bash $0 [options]"
    echo "Options:"
    echo " --add-users [usernames]  Can add single or multiple users, use space between users in case of multiple users. "
    echo " --install-packages   This will install necessary packages required for the user"
    echo " --configure-firewall This is to configure basic firewall rules for user security"
    echo " --help This displays current help message"
}

# Creating a main function and calling various functions from main function
main() {
    if [ $# -eq 0 ]; then
        display_help
        exit 1
    fi
    
    case $1 in
        --add-users)
            shift
            if [ $# -eq 0 ]; then
                echo "No usernames provided, Please specify atleast one username."
                exit 1
            fi
            
            for USER in "$@"; do
                add_user "$USER"
            done
        ;;
        
        --help)
            display_help
        ;;
        
        --install-packages)
            install_packages
        ;;
        
        --configure-firewall)
            configure_firewall
        ;;
        
        *)
            echo "Invalid option: $1"
            display_help
            exit 1
        ;;
        
    esac
}

main $@


