#!/bin/bash

###############################################################################################
######### Dojo information ####################################################################

# If you opted for Dojo to install bitcoind, all you need to do is edit `PATH_TO_DOJO_DOT_SH`
# below and then run it for the script to work.

#    ***** example entry: "/home/matthew/dojo_dir/docker/my-dojo/" ******

PATH_T0_DOJO_DOT_SH="/home/path/to/dojo_dir/docker/my-dojo/"

###############################################################################################
######## Options for if you're running your own bitcoind instance #############################

# If you have your own instance of bitcoind and are not utilizing Dojo's bitcoind container,
# change `EXTERNAL_BITCOIND` to "yes", and `BITCOIN_DIR` to the path for where your .bitcoin
# directory is located (most likely in /home/$USER/.bitcoin).

EXTERNAL_BITCOIND="yes"

# And change your `/home/username/.bitcoin` directory

#    ***** example entry: "/home/matthew/.bitcoin/" *****

BITCOIN_DIR="/home/path/to/.bitcoin/"

###############################################################################################
######### Options for using this sript on a machine Dojo isn't installed on ###################

# If you want to use this script remotely from a different machine, change SSH_OPTION to "yes"
# and modify the fields below appropriately.

# Also make sure you have the remote machine's public ssh key in your Dojo machine user`s
# `~/your_user_name/.ssh/authorized_keys` file.

# See the README.md `ssh` section for more info on how to set that up for passwordless ssh login

SSH_OPTION="no"
SSH_PORT="22"
USER_NAME="your_user_name"
IP="xxx.xxx.x.xxx"

###############################################################################################
###############################################################################################

SSH_CMD="ssh -tt -p $SSH_PORT $USER_NAME@$IP"
CMD1="cd $PATH_T0_DOJO_DOT_SH"
CMD2="cd $BITCOIN_DIR"

if [ "$EXTERNAL_BITCOIND" = "no" ]; then
	DOJO_CMD=("---EXIT---" "help" "version" "bitcoin-cli" "logs" "onion" "restart" \
			"start" "stop" "upgrade" "clean" "install" "uninstall")
else
	DOJO_CMD=("---EXIT---" "help" "version" "START bitcoind" "STOP bitcoind" \
			"bitcoin-cli" "logs" "onion" "restart" "start" "stop" "upgrade" \
			"clean" "install" "uninstall")
fi

LOG_MODULES=("---BACK---" "bitcoind" "db" "tor" "api" "tracker" "pushtx" "pushtx-orchest")

LENGTH_DOJO_CMD="${#DOJO_CMD[*]}"
LENGTH_LOG_MOD="${#LOG_MODULES[*]}"

while true; do

        GOBACK="no"
        echo "------------------------------------------------------------------------"
        echo "------------------- SAMOURAI DOJO INTERACTION SCRIPT -------------------"
	echo "------------------------------------------------------------------------"

	# Display options for user selection
        for ((i=0; i < $LENGTH_DOJO_CMD; i++)); do

		# Prints first element in column 1 by itself
		if [ $i -eq 0 ]; then
			echo " "
			echo "                  $i) ${DOJO_CMD[$i]}"

		# If number is odd print to column 1 and allow for next element to be printed
		# in column 2
		elif [ $((i%2)) -ne 0 ]; then

			# If it`s the last entry, ensure it`s not using `echo -n`
			if [[ $i -eq $LENGTH_DOJO_CMD-1 ]]; then
				echo " "
				echo "                  $i) ${DOJO_CMD[$i]}"
			else
		                echo " "
		                echo -n "                  $i) ${DOJO_CMD[$i]}"

				# Setup spacing for column 2
				temp22="${DOJO_CMD[$i]}"
				for ((j=0; j < 25 - $( expr length "$i) $temp22" ); j++)); do
					echo -n " "
				done
				unset temp22
			fi
		else
			echo "$i) ${DOJO_CMD[$i]}"
		fi
        done

	# Prompt for user selection
        while true; do
                echo " "
                read -p "Please enter a number corresponding to what you'd like to do: " NUM
                echo "------------------------------------------------------------------------"

		# Numbers outside available options loop back
                if [[ $NUM -lt 0 || $NUM -gt $LENGTH_DOJO_CMD-1 ]]; then
			unset NUM
                        echo " "
                        echo "Option not available, please try again..."
                        echo " "
                        sleep 1
			GOBACK="yes"
			break

		# Exit script
                elif [ $NUM -eq 0 ]; then
                        exit 0

		# For users to start up their own instance of bitcoind
		elif [ "${DOJO_CMD[$NUM]}" = "START bitcoind" ]; then
			if [ "$SSH_OPTION" = "yes" ]; then
				$SSH_CMD "bitcoind --daemon"
                        else
				bitcoind --daemon
			fi
			echo "bitcoind has been started..."
			echo " "
		# For users to stop their own instance of bitcoind
		elif [ "${DOJO_CMD[$NUM]}" = "STOP bitcoind" ]; then
			if [ "$SSH_OPTION" = "yes" ]; then
				$SSH_CMD "bitcoin-cli stop"
                        else
	                        bitcoin-cli stop
			fi
                        echo "bitcoind has been stopped..."
                        echo " "

		# Prompt for confirmation on "restart" "start" "stop" "upgrade" "clean" "install" "uninstall" options
                elif [[ $NUM -gt $LENGTH_DOJO_CMD-7 ]]; then
                        while true; do
                                echo " "
                                read -p "Please confirm you would like to ${DOJO_CMD[$NUM]} the Dojo [y/n]: " yn
                                case $yn in
                                        [Yy]* ) CONFIRM="yes"; break;;
                                        [Nn]* ) GOBACK="yes"; break;;
                                        * ) echo "Please answer y or n."
                                esac
                        done
                else
                        break
                fi

		# Prompt again if user selects uninstall to mitigate accidental wiping of data
		if [[ "${DOJO_CMD[$NUM]}" = "uninstall" && "$CONFIRM" = "yes" ]]; then
			unset CONFIRM
			while true; do
                                echo " "
                                read -p "Are you ABSOLUTELY sure you'd like to ${DOJO_CMD[$NUM]}? [y/n]: " yn
                                case $yn in
                                        [Yy]* ) CONFIRM="yes"break;;
                                        [Nn]* ) GOBACK="yes"; break;;
                                        * ) echo "Please answer y or n."
                                esac
                        done
		fi

		# Break primary while loop if user selects yes for confirmations
                if [[ "$GOBACK" = "yes" || "$CONFIRM" = "yes" ]]; then
                        break
                fi
        done

	# Options for logs
        if [ "${DOJO_CMD[$NUM]}" = "logs" ]; then

                while true; do

                        EXECUTE="no"

                        echo "---------------------------- Available Logs ----------------------------"
                        echo " "

			# Display options for user selection
		        for ((i=0; i < $LENGTH_LOG_MOD; i++)); do

		                # Prints first element in column 1 by itself
		                if [ $i -eq 0 ]; then
		                        echo " "
		                        echo "                  $i) ${LOG_MODULES[$i]}"

		                # If number is odd print to column 1 and allow for next element to be printed in column 2
		                elif [ $((i%2)) -ne 0 ]; then

					# If it`s the last entry, ensure it`s not using `echo -n`
					if [[ $i -eq $LENGTH_LOG_MOD-1 ]]; then
						echo " "
						echo "                  $i) ${LOG_MODULES[$i]}"
					else
			                        echo " "
			                        echo -n "                  $i) ${LOG_MODULES[$i]}"

			                        # Setup spacing for column 2
			                        temp33="${LOG_MODULES[$i]}"
			                        for ((j=0; j < 25 - $( expr length "$i) $temp33" ); j++)); do
			                                echo -n " "
			                        done
						unset temp33
					fi
		                else
		                        echo "$i) ${LOG_MODULES[$i]}"
		                fi
		        done

			echo " "
                        echo "-------------- press CTRL+C to exit the log when finished --------------"
                        echo " "
                        read -p "Please enter a number corresponding to what logs you'd like to view: " LNUM
                        echo " "

			# Numbers outside available options loop back
                        if [[ $LNUM -lt 0 || $LNUM -gt $LENGTH_LOG_MOD-1 ]]; then
                                echo "Option not available, please try again..."
                                echo " "
				sleep 2

			# User selection to go back
                        elif [ $LNUM -eq 0 ]; then
                                GOBACK="yes"
                                break

			# Additional command options for api tracker pushtx pushtx-orchest
                        elif [ $LNUM -gt 3 ]; then
                                echo "Available options to enter are '-d [VALUE]' **OR** '-n [VALUE]'"
                                echo " "
                                read -p "Please enter one now: " AVAIL_OPTIONS
                                EXECUTE="yes"
                        else
                                AVAIL_OPTIONS=""
                                EXECUTE="yes"
                        fi

                        if [ "$EXECUTE" = "yes" ]; then
				unset EXECUTE
                                trap "echo" SIGINT SIGTERM
				if [ "$SSH_OPTION" = "yes" ]; then
					if [[ "$EXTERNAL_BITCOIND" = "yes" && "${LOG_MODULES[$LNUM]}" = "bitcoind" ]]; then
						$SSH_CMD "$CMD2 && tail -f debug.log"
					else
						$SSH_CMD "$CMD1 && sudo ./dojo.sh logs ${LOG_MODULES[$LNUM]} $AVAIL_OPTIONS"
					fi
				else
					if [[ "$EXTERNAL_BITCOIND" = "yes" && "${LOG_MODULES[$LNUM]}" = "bitcoind" ]]; then
						$CMD2 && tail -f debug.log
					else
						$CMD1 && sudo ./dojo.sh logs ${LOG_MODULES[$LNUM]} $AVAIL_OPTIONS
					fi
				fi
                                trap - SIGINT SIGTERM
                        fi

                done
        fi

	# Bitcoin-cli interaction
        if [ "${DOJO_CMD[$NUM]}" = "bitcoin-cli" ]; then

                while true; do

                        read -p "bitcoin-cli [what command?] (x to go back): " BITCOIN_CLI_CMD

                        if [[ "$BITCOIN_CLI_CMD" = "X" || "$BITCOIN_CLI_CMD" = "x" ]]; then
                                break
                        else
				if [ "$SSH_OPTION" = "yes" ]; then
					if [ "$EXTERNAL_BITCOIND" = "no" ]; then
						$SSH_CMD "$CMD1 && sudo ./dojo.sh ${DOJO_CMD[$NUM]} $BITCOIN_CLI_CMD"
					else
						$SSH_CMD "bitcoin-cli $BITCOIN_CLI_CMD"
					fi
				else
					if [ "$EXTERNAL_BITCOIND" = "no" ]; then
						$CMD1 && sudo ./dojo.sh ${DOJO_CMD[$NUM]} $BITCOIN_CLI_CMD
                                        else
                                                bitcoin-cli $BITCOIN_CLI_CMD
                                        fi
				fi
                                echo "------------------------------------------------------------------------"
                        fi

                done

        elif [ "$GOBACK" != "yes" ]; then

		if [ "$SSH_OPTION" = "yes" ]; then
			$SSH_CMD "$CMD1 && sudo ./dojo.sh ${DOJO_CMD[$NUM]}"
		else
			$CMD1 && sudo ./dojo.sh ${DOJO_CMD[$NUM]}
		fi

                echo " "
                while true; do
                        read -p "Do something else? [y/n]: " yn
                        case $yn in
                                [Yy]* ) break;;
                                [Nn]* ) exit 0;;
                                * ) echo "Please answer y or n."
                        esac
                done
        fi
done
