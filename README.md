Samourai Dojo Interaction Script
================================

Script has been tested using:  
  Ubuntu 18.04  
  Dojo v1.2.0  

### Setup Instructions

1) Open a terminal up  
	`ctrl+alt+t`  

2) Navigate to a directory of where you want this script to live  
	`cd ~/your/directory`  
	
	OR, create a new `scripts` directory
	
	`if [ -d ~/scripts ]; then cd ~/scripts; else mkdir ~/scripts; cd ~/scripts; fi`  

3) Clone this repo  
	`git clone https://github.com/05nelsonm/dojo_interaction_script.git && cd dojo_interaction_script`  

4) Open the script up in an editor by executing in terminal  
	`nano control_dojo.sh`  

5) Follow the instructions at the top of the script, entering the necessary information  

6) Make the script executable by executing in terminal  
	`chmod +x control_dojo.sh`  

7) Run the script by executing in terminal  
	`./control_dojo.sh`  

### Add Application Launcher Icon

1) Navigate to the directory where you cloned or downloaded/extracted this project to  

2) Open the `.desktop` file up in an editor by executing in terminal  
	`nano samourai-dojo.desktop`  

3) Update the ***two*** `***starred***` fields with the correct information  
	***Note:*** must use full paths, such as `/home/matthew/dojo_dir/`  

4) Move the `.desktop` file into your applications directory  
	`sudo mv samourai-dojo.desktop /usr/share/applications/`  

### Using the script remotely via ssh

I set it up to be used with passwordless login via ssh, also, as you need sudo privledges to
interact with the ./dojo [commands]. I did it so that I can control the Dojo from my Host machine.
This option may not be for you if you don't want to permit passwordless login via ssh to the machine running
your Dojo.

I have my VMs set up with passwordless pubkeys and UFW so that my host is the only machine that can
login to the VMs via ssh. It is somewhat of a security risk if you do not structure yourself properly,
so please be cautious.

If you wanted to use it remotely via SSH, below are haggard instructions for setting that up to work.


```
 My ssh setup as an example...                               passwordless       ########
                                                         |-------------------> # VM 1 #
                                                         |     pubkey          ########
##########      pubkey + 2FA      ################       |                  UFW (Host machine &
# Laptop # ---------------------> # Host Machine # <-----|			other VMs)
##########        user pass       ################       |
                              UFW (Laptop & VMs Only)    |   passwordless      ########
                                                         |-------------------> # VM 2 #
                                                         |      pubkey         ########
                                                         |                  UFW (Host machine &
                                                         | 			other VMs)
                                                         | 
                                                         |    passwordless     ########
                                                         |-------------------> # VM 3 #   
                                                         |      pubkey         ########
                                                         |                  UFW (Host machine &
                                                        etc.			other VMs)



## **On your remote machine (the computer not running Dojo)**

## If you have already generated passwordless ssh keys, go to STEP 2
## STEP 1:
$ ssh-keygen -b 4096
      enter --> enter --> enter
      
## Correct permissions
$ sudo chmod 700 ~/.ssh

## Get your public key
## STEP 2:
$ cat ~/.ssh/id_rsa.pub

		## Copy the pubkey

## Add your remote machine user public key as an authorized login to the primary user on your Dojo
##**On your machine that is running Dojo**
## STEP 3:
$ if [ -d ~/$USER/.ssh ]; then nano ~/$USER/.ssh/authorized_keys; else mkdir ~/$USER/.ssh; nano ~/$USER/.ssh/authorized_keys; fi

		##Paste your non-root user's pubkey into the Dojo machine's user's authorized_key file

		## Save and exit
		ctrl+x --> y --> return

## Correct permissions && ensure correct ownership
$ sudo chmod 600 ~/$USER/.ssh/authorized_keys && sudo chown $USER:$USER ~/$USER/.ssh/authorized_keys

## Configure sshd_config on Dojo machine
## If you login to the machine that runs Dojo from anywhere else, you will need to add that machine's user's pubkyes to
## the user's authorized_keys file, otherwise you will be locked out...

$ sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
$ sudo nano /etc/ssh/sshd_config

	## Alterations to /etc/ssh/sshd_config:
	Port 2222 # <-- only if you want to change it, make sure to update UFW as well as the control_dojo.sh script...
	PermitRootLogin no
	PubkeyAuthentication yes
	PasswordAuthentication no
				
	## Save and exit
	ctrl+x --> y --> return

## Restart sshd service
$ sudo service sshd restart

## DO NOT EXIT OUT OF THE TERMINAL CURRENTLY LOGGED INTO YOUR DOJO MACHINE IN A SEPERATE TERMINAL FROM YOUR REMOTE
## MACHINE TO ENSURE EVERYTHING WORKS! You'll be locked out, and if you're running things headless, you'll have to
## hook up a monitor and keyboard to fix it.

## On a remote machine you set this up to work with, open a terminal and try to login to the Dojo via ssh.

## Done
```
