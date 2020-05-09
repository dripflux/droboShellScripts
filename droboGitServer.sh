#!/usr/bin/env sh

# Author: Drip.Flux
# Description: Server side (on Drobo) script for creating bare Git repo.
#   Part of droboShellScripts project.
# Dependencies:
#   - Drobo Dashboard Admin Account
#   - Drobo App > Git SCM
#   - sh : default sh on Drobo, sh compliant on client
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
	#   0  : (normal) Git repo     initialized on Drobo
	#   1+ : ERROR:   Git repo NOT initialized on Drobo
	# Perform Function
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
		return 1
	fi
	isValidDirectoryName "${DROBO_REPOS_DIR_PATH}"
	if (( 0 != ${?} )) ; then  # Invalid driectroy name - $DROBO_REPOS_DIR_PATH from libDroboShellGit.sh
		return 1
	fi
	isValidDirectoryName "${1}"
	if (( 0 != ${?} )) ; then  # Invalid driectroy name - ${1} from caller
		return 1
	fi
	DROBO_NEW_GIT_DIR="${DROBO_REPOS_DIR_PATH}${1}.git"
	git init --bare "${DROBO_NEW_GIT_DIR}"
	return ${?}
}

# Call main()
main ${@}
