#!/usr/bin/env sh

# Author: Drip.Flux
# Description: Library for common routines related to Drobo Git SCM.
#   Intended to be sourced by other shell scripts.
#   Part of droboShellScripts project.
# Dependencies:
#   - Drobo Dashboard Admin Account
#   - Drobo App > Git SCM
#   - sh : default sh on Drobo, sh compliant on client
#   - ssh : ssh compliant on Drobo (Drobo App: Dropbear), ssh compliant on client

# Declare Global Variables
## Personalize for User's Drobo
DROBO_REPOS_DIR_PATH="/mnt/DroboFS/repos/"  # Absolute path of directory for Git repos on Drobo
## Common Across Drobo
DROBO_GIT_PACK_DIR_PATH="/mnt/DroboFS/Shares/DroboApps/git/bin/"  # Absolute path of directory for Git binaries on Drobo
DROBO_GIT_PROTOCOL="ssh"  # Protocol used to communicate with Git on Drobo
DROBO_GIT_URL=""  # Generated as part of script

function generateRepoURL () {
	# Description: Generates URL for Git repo on Drobo, updates $DROBO_GIT_URL accordingly
	# Args:
	#   ...
	# Return:
	#   0 : (normal) $DROBO_GIT_URL     Updated
	#   1 : ERROR:   $DROBO_GIT_URL NOT Updated
	:  # Placeholder, syntactic NOP
}

function isInRangeInt () {
	# Description:
	# Args:
	#   ${1) : Minimum integer of range
	#   ${2} : Maximum integer of range
	#   #{3} : Integer to test
	# Return:
	#   0 :     IN Range
	#   1 : NOT IN Range
	#   2 : ERROR: Incorrect Usage
	# Perform Function
	case $# in  # Argument count check
		3 )  # Normal
			if (( ${3} < ${1} )) ; then
				return 1
			fi
			if (( ${3} > ${2} )) ; then
				return 1
			fi
			;;
		* )  # ERROR: Incorrect number of arguments
			return 2
			;;
	esac
	return 0
}

function isValidDirectoryName () {
	# Description: Determines if ${1} is a valid directory name or not
	# Args:
	#   ${1} : Directory name to validate
	# Return:
	#   0 : VALID   Directory Name
	#   1 : INVALID Directroy Name
	#   2 : ERROR: Incorrect Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
		return 2
	fi
	return 0
}

function isValidDroboName () {
	# Description: Determines if ${1} is a valid Drobo Name or not
	# Args:
	#   ${1} : Drobo name to validate
	# Return:
	#   0 : VALID   Drobo Name
	#   1 : INVALID Drobo Name
	#   2 : ERROR: Incorrect Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
		return 2
	fi
	return 0
}

function isValidProtocol () {
	# Description: Determines if ${1} is a valid Git + Drobo protocol or not
	# Args:
	#   0 : VALID   Protocol
	#   1 : INVALID Protocol
	#   2 : ERROR: Incorrect Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
		return 2
	fi
	return 0
}

function isValidUsername () {
	# Description: Determines if ${1} is a valid username or not
	# Args:
	#   ${1} : Username to validate
	# Return:
	#   0 : VALID   Username
	#   1 : INVALID Username
	#   2 : ERROR: Incorrect Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
		return 2
	fi
	return 0
}