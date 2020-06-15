#!/usr/bin/env bash

# Author: Drip.Flux
# Description: Client side (on local host) script for creating bare Git repo on Drobo, and cloning repo on local host.
#   Part of droboShellScripts project.
# Dependencies:
#   - Drobo Dashboard Admin Account
#   - Drobo App > Git SCM
#   - Drobo Apps > Bash : sh (default shell on Drobo) does not support export -f
#   - ssh : ssh compliant on Drobo (Drobo Apps > Dropbear), ssh compliant on client
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
	echo "[on Drobo]"
	:  # Placeholder, syntactic NOP
	## Actions on local host
	echo "[on localhost]"
	droboGitClone ${1}
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
	cd ${1}
	droboGitConfig origin
	if (( 0 != ${?} )) ; then  # ERROR: ...
		return 1
	fi
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
	echo "[on Drobo]"
	droboSSHgitInit ${1}
	if (( 0 != ${?} )) ; then  # ERROR: ...
		return 3
	fi
	## Actions on local host
	echo "[on localhost]"
	droboGitClone .
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
	droboGitConfig origin
	if (( 0 != ${?} )) ; then  # ERROR: ...
		return 1
	fi
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
	echo "[on Drobo]"
	droboSSHgitInit ${1}
	## Actions on local host
	echo "[on localhost]"
	git remote add ${DROBO_GIT_NAME} ${DROBO_GIT_URL}
	droboGitConfig ${DROBO_GIT_NAME}
	git push --all ${DROBO_GIT_NAME}
	return 0
}

function droboSSHgitInit () {
	# Description: SSH to Drobo, execute droboGitServer.sh
	# Args:
	#   ${1} : File system friendly name of repo to initialize on the Drobo
	# Return:
	#   0 : (normal) Git repo     setup on Drobo
	#   2 : ERROR:   Git repo NOT setup on Drobo
	#   4 : ERROR:   Incorrect sub-command usage
	# Perform Function
	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of function arguments
		return 4
	fi
	ssh ${DROBO_USERNAME}@${DROBO_NET_ID} "export PATH=${DROBO_ENV_PATH} && droboGitServer.sh init ${1}"
	case ${?} in
		0 )    # Normal return
			;;
		255 )  # ERROR: ssh failed
			echo "ERROR: ssh to Drobo failed" >&2
			return 2
			;;
		* )    # ERROR: droboGitServer.sh failed
			echo "ERROR: droboGitServer.sh on Drobo failed, exit status: ${?}" >&2
			return 2
			;;
	esac
	return 0
}

function droboGitClone () {
	# Description: Clone repo on Drobo to local host using ssh
	# Args:
	#   ${1} : File system friendly name of repo to initialize on the Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host
	#   1 : ERROR:   Git repo NOT setup on local host
	#   4 : ERROR:   Incorrect sub-command usage
	# Perform Function
	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of function arguments
		return 4
	fi
	git clone -u ${DROBO_GIT_PACK_DIR_PATH}/git-upload-pack ${DROBO_GIT_URL} ${1}
	if (( 0 != ${?} )) ; then  # ERROR: Failed to clone repo from Drobo
		echo "ERROR: Failed to clone repo from Drobo" >&2
		return 1
	fi
	return 0
}

function droboGitConfig () {
	# Description:
	# Args:
	#   ${1} : Name of remote in Git for Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host
	#   1 : ERROR:   Git repo NOT setup on local host
	#   4 : ERROR:   Incorrect sub-command usage
	# Perform Function
	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of function arguments
		return 4
	fi
	git config remote.${1}.uploadpack ${DROBO_GIT_PACK_DIR_PATH}/git-upload-pack && git config remote.${1}.receivepack ${DROBO_GIT_PACK_DIR_PATH}/git-receive-pack
	if (( 0 != ${?} )) ; then  # ERROR: Failed to configure repo on local host
		echo "ERROR: Failed to configure repo on local host" >&2
		return 1
	fi
	return 0
}

# Call main()
main ${@}
