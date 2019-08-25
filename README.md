Samourai Dojo Interaction Script
================================

Script has been tested using:  
  Ubuntu 18.04  
  Dojo v1.2.0  

### Setup Instructions

1) Clone or download/extract this project to a directory of your liking  

2) Open a terminal and navigate to that directory  

3) Open the script up in an editor by executing in terminal:  `nano control_dojo.sh`  

4) Follow the instructions at the top of the script

4) Make the script executable by executing in terminal: `chmod +x control_dojo.sh`  

5) Run the script by executing in terminal: `./control_dojo.sh`  

### Add Application Launcher Icon

1) Navigate to the directory where you cloned or downloaded/extracted this project to

2) Open the `.desktop` file up in an editor by executing in terminal: `nano samourai-dojo.desktop`  

3) Update the ***two*** `***starred***` fields with the correct information  
	***Note:*** must use full paths, such as `/home/matthew/dojo_dir/`  

4) Move the `.desktop` file into your applications directory: `sudo mv samourai-dojo.desktop /usr/share/applications/`

### Using the script remotely via ssh

I set it up to be used with passwordless root login via ssh, also, as you need sudo privledges to
interact with the ./dojo [commands]. I did it so that I can control the Dojo from my Host machine.
This option may not be for you if you don't want to permit root login via ssh to the machine running
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



## **On the machine that runs Dojo, as non-root user** ##

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

## Add your non-root user as an authorized login to your root user on your Dojo
## STEP 3:
$ sudo -s
$ if [ -d /root/.ssh ]; then nano /root/.ssh/authorized_keys; else mkdir /root/.ssh; nano /root/.ssh/authorized_keys; fi

		##Paste your non-root user's pubkey into your root user's authorized_key file

		## Save and exit
		ctrl+x --> y --> return

## Correct permissions
$ chmod 600 /root/.ssh/authorized_keys

## Log out of root user
$ exit

## On your laptop or remote machine that you login to your Dojo with,
## repeate STEP 1 & STEP 2, then do STEP 3 again for your Dojo root user

## Add your laptop or remote machine's pubkeys to the authorized_keys of your non-root Dojo user
## STEP 4:
$ nano ~/.ssh/authorized_keys

	### Paste your laptop's pubkey into your non-root user's authorized_key file

	### Save and exit
	ctrl+x --> y --> return

## Correct permissions
$ sudo chmod 600 ~/.ssh/authorized_keys

## Configure sshd_config on Dojo machine
## If you login to the machine that runs Dojo from anywhere else, you will need to add that machine's pubkyes to
## the user's authorized_keys file, otherwise you will be locked out...

$ sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
$ sudo nano /etc/ssh/sshd_config

	## Alterations to /etc/ssh/sshd_config:
	Port 2222 # <-- only if you want to change it, make sure to update UFW and the script above...
	PermitRootLogin yes
	PubkeyAuthentication yes
	PasswordAuthentication no
				
	## Save and exit
	ctrl+x --> y --> return

## Restart sshd service
$ sudo service sshd restart

## DO NOT EXIT OUT OF THE TERMINAL CURRENTLY LOGGED INTO YOUR DOJO MACHINE

## On a remote machine you set this up to work with, open a terminal and try to login to the Dojo via ssh.
## Be sure to try loging into both Dojo's non-root & root users

## Done
```
