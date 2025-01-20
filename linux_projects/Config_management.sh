#User when enters username to create user, this function checks if user already exists and prompts to enter a newuser name. If username is unique it creates user
#and assigns a temporary password and forces user to change password on first login.
add_user () {
    echo "This function creates users"
}

#This function installs packages based on the package manager
install_packages () {
    echo "This function installs packages"
}

configure_firewall () {
    echo "This fucntion provides basic security to the users by configuring basic firewall rules"
}

#Display help function which gives instructions to user when user doesn't know how to run the script
display_help()
{
    echo "The Below instructions help you on how to run the script"
    echo "Usage: $0 [options]"
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

main "$@"


