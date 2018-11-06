#!/bin/bash



show_menu(){

	echo "===Welcome to SSH User Management. Enter a number to make your choice==="
	echo "|_ 1. Create New User (random username)"
	echo "|_ 2. Create a New User (you need to enter the user name)"
	echo "|_ 3. Activate Expired User or change a user's expiry date"
	echo "|_ 4. Deactivate User" 
	echo "|_ 5. Delete Existing User"
	echo "|_ 6. Delete All Users provisioned by this script"
	echo " "
    	echo "===Please enter a menu option and enter or enter to exit."
    	read input

  	while [ input != '' ]
  	do
    		if [[ $input = "" ]]; then
      			exit;
    		else
      			case $input in
      				1) clear;
				echo "You chose to create a random user"
				Random_User=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
				create_user ${Random_User}
				if [ $? -eq 0 ]; then
                                        echo "User created successfully"
                                else
                                	echo "User creation was not successful"
                                fi

      				show_menu;
      				;;

      				2) clear;
				echo "You chose to create a user"
				echo "Please enter a valid User Name which does not exist already, without spaces and special characters"
				echo "If you dont follow these rules, the results might be unexpected, which might cause the server the go inaccessible"
				read customUserName
				if [[ ! -z $customUserName ]]; then
					create_user ${customUserName}
					if [ $? -eq 0 ]; then
	                                        echo "User created successfully"
        	                        else
                	                        echo "User creation was not successful"
                        	        fi

				fi
	      			show_menu;
      				;;

      				3) clear;
      				echo "You chose to change the expiry date of a user"
				echo "Please enter the username:"
				read changeUserName
				echo "Please enter how many days do you want this account to be active from today"
				read userDays
				chage -E `date -d "${userDays} days" +"%Y-%m-%d"` ${changeUserName}
				if [ $? -eq 0 ]; then
                                        echo "Operation Successful. Expiry set to `date -d "${userDays} days" +"%Y-%m-%d"` for user $changeUserName"
					chage -l ${changeUserName}
                                else
                                        echo "User Expiry date set failed"
                                fi
	      			show_menu;
      				;;

      				4) clear;
				echo "Please enter the username which you want to expire"
				read expireUserName
				chage -E `date -d "-1 days" +"%Y-%m-%d"` ${expireUserName}
				chage -l ${expireUserName}
      				show_menu;
	      			;;

				5) clear;
				echo "You chose to delete a user"
				echo "Please enter an existing user"
				read user2Del
				userdel -r ${user2Del}
				if [ $? -eq 0 ]; then
					echo "User Deletion was successful for ${user2Del}"
					rm -rf ${HOME}/keys/${user2Del}
					rm -rf ${HOME}/keys/${user2Del}.pub
				else
    					echo "User Deletion was NOT successful"
				fi
					
				show_menu

				;;

				6) clear;
				echo "You chose to delete all users provisioned by this script"
				echo "Press Y (Capital Y) if you are sure"
				read choice
				if [ $choice = "Y" ]; then
					echo "Deleting All Users"
					for userExists in `ls -1 ${HOME}/keys | grep -v "\."`; do
						userdel -r  $userExists
						if [ $? -eq 0 ]; then
                                        		echo "User Deletion was successful $userExists"
                                        		rm -rf ${HOME}/keys/${userExists}
                                        		rm -rf ${HOME}/keys/${userExists}.pub
                                		else
                                        		echo "User Deletion was NOT successful for ${userExists}"
                                		fi
					done
				else
					echo "You chose not to delete all the users"
				fi
				show_menu
				;;

      				x)exit;
      				;;

      				\n)exit;
	      			;;
	
	      			*)clear;
      				show_menu;
      				;;
      			esac
    		fi
  	done
}

create_user(){

	echo "User being created is $1"	
	echo "How many days should the user the be active for? "
	read activeDays
	
	New_User=$1
	adduser -m -e `date -d "${activeDays} days" +"%Y-%m-%d"` ${New_User}
	ssh-keygen -b 2048 -t rsa -f ${HOME}/keys/${New_User} -q -N ""
	chmod 600 ${HOME}/keys/${New_User}*
	mkdir -p /home/${New_User}/.ssh
	chmod 700 /home/${New_User}/.ssh
	cat ${HOME}/keys/${New_User}.pub > /home/${New_User}/.ssh/authorized_keys
	chmod 600 /home/${New_User}/.ssh/authorized_keys
	chown -R ${New_User}:${New_User} /home/${New_User}/.ssh

	echo "User Creation task is complete"
	echo "New User: ${New_User}"
	chage -l ${New_User}
	echo "Private key to share for ssh"
	cat ${HOME}/keys/${New_User}

}

HOME="/dynUser"



clear
show_menu
