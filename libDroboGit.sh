#!/usr/bin/env bash

# Author: Drip.Flux
# Description: Library for common routines related to Drobo Git SCM.
#   Intended to be sourced by other shell scripts.
#   Part of droboShellScripts project.
# Dependencies:
#   - Drobo Dashboard Admin Account
#   - Drobo Apps > Git SCM
#   - Drobo Apps > Bash : sh (default shell on Drobo) does not support export -f
#   - ssh : ssh compliant on Drobo (Drobo Apps > Dropbear), ssh compliant on client

# Declare Global Variables
## Personalize for User's Drobo
export DROBO_REPOS_DIR_PATH="/mnt/DroboFS/repos/"  # Absolute path of directory for Git repos on Drobo
export DROBO_GIT_SCRIPTS_PATH="/mnt/DroboFS/bin:/mnt/DroboFS/bin/include"
## Common Across Drobo
export DROBO_DEFAULT_PATH="/bin:/sbin:/usr/local/bin"
export DROBO_GIT_PACK_DIR_PATH="/mnt/DroboFS/Shares/DroboApps/git/bin"  # Absolute path of directory for Git binaries on Drobo
export DROBO_GIT_PROTOCOL="ssh"  # Protocol used to communicate with Git on Drobo
export DROBO_GIT_URL=""  # Generated as part of script
export DROBO_ENV_PATH="${DROBO_DEFAULT_PATH}:${DROBO_GIT_SCRIPTS_PATH}"

function generateRepoURL () {
	# Description: Generates URL for Git repo on Drobo, updates $DROBO_GIT_URL accordingly
	# Args:
	#   ...
	# Return:
	#   0 : (normal) $DROBO_GIT_URL     Updated
	#   1 : ERROR:   $DROBO_GIT_URL NOT Updated
	# Perform Function
	DROBO_GIT_URL="${DROBO_GIT_PROTOCOL}://${DROBO_USERNAME}@${DROBO_NET_ID}${DROBO_GIT_DIR}.git"
	return 0
}
export -f generateRepoURL

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
export -f isInRangeInt

function isValidDirectoryName () {
	# Description: Determines if ${1} is a valid directory name or not
	# Args:
	#   ${1} : Directory name to validate
	# Return:
	#   0 : VALID   Directory Name
	#   1 : INVALID Directroy Name
	#   2 : ERROR: Incorrect Usage
	# Perform Function
	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
		return 2
	fi
	# Validate Directory Name
	### No PATH Traversal
	:  # Placeholder, syntactic NOP
	### No Command Exec
	:  # Placeholder, syntactic NOP
	return 0
}
export -f isValidDirectoryName

function isValidDroboName () {
	# Description: Determines if ${1} is a valid Drobo Name or not
	# Args:
	#   ${1} : Drobo name to validate
	# Return:
	#   0 : VALID   Drobo Name
	#   1 : INVALID Drobo Name
	#   2 : ERROR: Incorrect Usage
	# Perform Function
	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
		return 2
	fi
	# Validate Drobo Name
	## No PATH Traversal
	:  # Placeholder, syntactic NOP
	## No Command Exec
	:  # Placeholder, syntactic NOP
	return 0
}
export -f isValidDroboName

function isValidDroboNetID () {
	# Description: Determines if ${1} is a valid Drobo Network Identifier (ID) or not
	# Args:
	#   ${1} : Drobo name to validate
	# Return:
	#   0 : VALID   Drobo Name
	#   1 : INVALID Drobo Name
	#   2 : ERROR: Incorrect Usage
	# Perform Function
	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
		return 2
	fi
	# Validate Drobo Network ID
	## No PATH Traversal
	:  # Placeholder, syntactic NOP
	## No Command Exec
	:  # Placeholder, syntactic NOP
	return 0
}
export -f isValidDroboNetID

function isValidProtocol () {
	# Description: Determines if ${1} is a valid Git + Drobo protocol or not
	# Args:
	#   0 : VALID   Protocol
	#   1 : INVALID Protocol
	#   2 : ERROR: Incorrect Usage
	# Perform Function
	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
		return 2
	fi
	## Validate Protocol
	### No PATH Traversal
	:  # Placeholder, syntactic NOP
	### No Command Exec
	:  # Placeholder, syntactic NOP
	return 0
}
export -f isValidProtocol

function isValidUsername () {
	# Description: Determines if ${1} is a valid username or not
	# Args:
	#   ${1} : Username to validate
	# Return:
	#   0 : VALID   Username
	#   1 : INVALID Username
	#   2 : ERROR: Incorrect Usage
	# Perform Function
	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
		return 2
	fi
	## Validate Username
	### No PATH Traversal
	:  # Placeholder, syntactic NOP
	### No Command Exec
	:  # Placeholder, syntactic NOP
	return 0
}
export -f isValidUsername
