#!/usr/bin/env bash


# Author: Drip.Flux
# Description: Server side (on Drobo) script for creating bare Git repo.
#   Part of droboShellScripts project.
# Dependencies:
#   - Drobo Dashboard Admin Account
#   - Drobo Apps > Git SCM
#   - Drobo Apps > Bash : sh (default shell on Drobo) does not support export -f
# Expectations:
#   - $DROBO_REPOS_DIR_PATH exists and user context has read, write, and execute permissions


# Required Sources
source libDroboGit.sh


# Declare Global Variables


function main () {
	# Description: Main control flow of program
	# Args:
	#   ${1} : File system friendly name of repo to create
	# Return:
	#   0 : (normal) Git repo     setup on Drobo
	#   1 : ERROR:   Git repo NOT setup on Drobo
	#   2 : (help)   Git repo NOT setup on Drobo
	#   4 : ERROR:   Incorrect [sub-command] usage, or invalid environment

	## Validate Environment
	isValidEnvironment ${@}
	if (( 0 != ${?} )) ; then  # Invalid environment
		usage
		return 4
	fi
	## Perform sub-command
	case ${1} in
		help )
			return 2
			;;
		init )
			git init --bare "${DROBO_NEW_GIT_DIR}"
			;;
		* )
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

	echo "droboGitServer.sh <help|init>"
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
	if [[ "${1}" = "help" ]] ; then
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
	DROBO_NEW_GIT_DIR="${DROBO_REPOS_DIR_PATH}${2}.git"
	isValidDirectoryName "${DROBO_NEW_GIT_DIR}"
	if (( 0 != ${?} )) ; then  # Invalid directory name - ${DROBO_NEW_GIT_DIR}
		return 1
	fi
	return 0
}


# Call main()
main ${@}
