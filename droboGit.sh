#!/usr/bin/env sh

# Author: Drip.Flux
# Description: Client side (on local host) script for creating bare Git repo on Drobo, and cloning repo on local host.
#   Part of droboShellScripts project.
# Dependencies:
#   - Drobo Dashboard Admin Account
#   - Drobo App > Git SCM
#   - sh : default sh on Drobo, sh compliant on client
#   - ssh : ssh compliant on Drobo (Drobo App > Dropbear), ssh compliant on client
# Expectations:
#   - $DROBO_REPOS_DIR_PATH exists and user context has read, write, and execute permissions

# Required Sources
source libDroboGit.sh

# Declare Global Variables
## Personalize for User's Drobo
source droboID.sh  # Contains Drobo system and user identification, not part of repo, expected to be in $PATH
# Expect following variables to be assigned in droboID.sh
# - DROBO_GIT_NAME : Name to use as remote for Git; i.e. git remote
# - DROBO_NET_ID : Network identifier of Drobo, IP address or hostname
# - DROBO_USERNAME : Username on Drobo to authenticate as for Git commands, typically the Admin (Administrator) user from Drobo Dashboard

function main () {
	# Description: Main control flow of program
	# Args:
	#   ${1} : File system friendly name of repo to create
	# Return:
	#   0 : (normal) Git repo     initialized on local host
	#   1 : ERROR:   Git repo NOT initialized on local host nor Drobo
	#   2 : ERROR:   Git repo NOT initialized on local host, but repo initialized on Drobo
	# Perform Function
	# Use cases (sub-cmds):
	#   clone  : [2 args] ...
	#   init   : [2 args] ...
	#   remote : [2 args] ...
	:  # Place holder NOP for syntactical correctness
}

# Call main()
main ${@}
