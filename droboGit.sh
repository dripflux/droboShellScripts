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
	#   0 : (normal) Git repo     setup on local host and Drobo
	#   1 : ERROR:   Git repo NOT setup on local host, but repo     setup on Drobo
	#   2 : ERROR:   Git repo     setup on local host, but repo NOT setup on Drobo
	#   3 : ERROR:   Git repo NOT setup on local host, and repo NOT setup on Drobo
	#   4 : ERROR:   Incorrect [sub-command] usage, or invalid environment
	# Use cases (sub-commands):
	#   clone  : [2 args] ...
	#   help   : [1-2 args] ...
	#   init   : [2 args] ...
	#   remote : [2 args] ...
	# Perform Function
	## Validate Environment
	isValidEnvironment ${@}
	if (( 0 != ${?} )) ; then  # Invalid environment
		return 4
	fi
	## Perform sub-command
	case ${1} in
		clone )
			subcmdClone ${2}
			;;
		help )
			usage
			;;
		init )
			subcmdInit ${2}
			;;
		remote )
			subcmdRemote ${2}
			;;
		* )  # ERROR: Unknown sub-command
			echo "ERROR: Unknown sub-command (${1})" >&2
			return 4
			;;
	esac
	return ${?}
}

function usage () {
	# Description: Output usage statement
	# Args:
	#   (none)
	# Return:
	#   (none)
	# Perform Function
	echo "droboGit.sh <clone|help|init|remote>"
	return 0
}

function isValidEnvironment () {
	# Description: Determines if environment is valid or not
	# Args:
	#   ${@} : Command line arguments
	# Return:
	#   0 : VALID   environment
	#   1 : INVALID environment
	isInRangeInt 1 2 $#
	if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
		return 1
	fi
	if [ ${1} = "help" ] ; then
		return 0
	fi
	isInRangeInt 2 2 $#
	if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
		return 1
	fi
	isValidDirectoryName "${DROBO_REPOS_DIR_PATH}"
	if (( 0 != ${?} )) ; then  # Invalid directory name - $DROBO_REPOS_DIR_PATH from libDroboShellGit.sh
		return 1
	fi
	isValidDirectoryName "${2}"
	if (( 0 != ${?} )) ; then  # Invalid directory name - ${2} from caller
		return 1
	fi
	DROBO_GIT_DIR="${DROBO_REPOS_DIR_PATH}${2}"
	isValidDirectoryName "${DROBO_GIT_DIR}"
	if (( 0 != ${?} )) ; then  # Invalid directory name - ${DROBO_GIT_DIR}
		return 1
	fi
	isValidDroboName ${DROBO_GIT_NAME}
	if (( 0 != ${?} )) ; then  # Invalid
		return 1
	fi
	isValidDroboNetID ${DROBO_NET_ID}
	if (( 0 != ${?} )) ; then  # Invalid
		return 1
	fi
	isValidUsername ${DROBO_USERNAME}
	if (( 0 != ${?} )) ; then  # Invalid
		return 1
	fi
	isValidProtocol ${DROBO_GIT_PROTOCOL}
	if (( 0 != ${?} )) ; then  # Invalid
		return 1
	fi
	generateRepoURL
	if (( 0 != ${?} )) ; then  # Invalid
		return 1
	fi
	return 0
}

function subcmdClone () {
	# Description: Clone an existing repo from the Drobo to the local host
	# Args:
	#   ${1} : File system friendly name of repo to clone from the Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host and Drobo
	#   1 : ERROR:   Git repo NOT setup on local host, but repo     found on Drobo
	#   3 : ERROR:   Git repo NOT setup on local host, and repo NOT found on Drobo
	#   4 : ERROR:   Incorrect sub-command usage
	# Perform Function
	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of function arguments
		return 4
	fi
	## Actions on Drobo
	:  # Placeholder, syntactic NOP
	## Actions on local host
	# git clone ${DROBO_GIT_URL} ${2}
	# Config Drobo (origin) Git pack directory path
	:  # Placeholder, syntactic NOP
	return 0
}

function subcmdInit () {
	# Description: Initialize a new repo on the Drobo and clone to the local host
	# Args:
	#   ${1} : File system friendly name of repo to initialize on the Drobo and clone to local host
	# Return:
	#   0 : (normal) Git repo     setup on local host and Drobo
	#   1 : ERROR:   Git repo NOT setup on local host, but repo     setup on Drobo
	#   3 : ERROR:   Git repo NOT setup on local host, and repo NOT setup on Drobo
	#   4 : ERROR:   Incorrect sub-command usage
	# Perform Function
	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of function arguments
		return 4
	fi
	## Actions on Drobo
	# ssh to Drobo, call droboGitServer.sh init ${2}
	:  # Placeholder, syntactic NOP
	## Actions on local host
	# git clone ${DROBO_GIT_URL} ${2}
	# Config Drobo (origin) Git pack directory path
	:  # Placeholder, syntactic NOP
	return 0
}

function subcmdRemote () {
	# Description: Initialize a new repo on the Drobo as a remote to an existing repo on the local host, pushes existing repo to Drobo
	# Args:
	#   ${1} : File system friendly name of repo to initialize on the Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host and Drobo
	#   2 : ERROR:   Git repo     setup on local host, but repo NOT setup on Drobo
	#   3 : ERROR:   Git repo NOT setup on local host, and repo NOT setup on Drobo
	#   4 : ERROR:   Incorrect sub-command usage
	# Perform Function
	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of function arguments
		return 4
	fi
	## Actions on Drobo
	# ssh to Drobo, call droboGitServer.sh init ${2}
	:  # Placeholder, syntactic NOP
	## Actions on local host
	# git remote add ${DROBO_NAME} ${DROBO_GIT_URL}
	# Config Drobo (${DROBO_NAME}) Git pack directory path
	# git push --all ${DROBO_NAME}
	:  # Placeholder, syntactic NOP
	return 0
}

# Call main()
main ${@}
