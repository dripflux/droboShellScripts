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


# Save script name
SELF="${0}"


# Required Sources
source libDroboGit.sh


# Declare Global Variables
# Personalize for User's Drobo
source droboID.sh  # Contains Drobo system and user identification, not part of repo, expected to be in $PATH
# Expect following variables to be assigned in droboID.sh
# - DROBO_GIT_NAME : Name to use as remote for Git; i.e. git remote $DROBO_GIT_NAME
# - DROBO_NET_ID   : Network identifier of Drobo, IP address or hostname
# - DROBO_USERNAME : Username on Drobo to authenticate as for Git commands, typically the Admin (Administrator) user from Drobo Dashboard


main () {
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
	#   help   : [1-2 args] ...
	#   clone  : [2 args] ...
	#   init   : [2 args] ...
	#   mirror : [2 args] ...
	#   remote : [2 args] ...

	# Set up working set
	subcommand="${1}"
	shift
	# Core actions
	# Validate Environment
	isValidEnvironment "${@}"
	# if (( 0 != ${?} )) ; then  # Invalid environment
	# 	usage
	# 	return 4
	# fi
	# Perform subcommand
	case "${subcommand}" in
		help )     # Display this help message supports single term filtering
			searchTerm="${1}"
			shift
			usage "${searchTerm}"
			;;
		manual )   # Display full manual
			:
			;;
		list )     # List repositories on Drobo
			:
			;;
		clone )    # Clone repository that exists on Drobo but does not exist on local system
			repoSlug="${1}"
			shift
			subcommandClone "${repoSlug}"
			;;
		init )     # Initialize repository that does not exist on Drobo and does not exist on local system
			repoSlug="${1}"
			shift
			subcommandInit "${repoSlug}"
			;;
		mirror )   # Mirror repository that does exist on local system that does not exist on Drobo
			repoSlug="${1}"
			shift
			subcommandMirror "${repoSlug}"
			;;
		remote )   # Add Drobo as remote for repository that does exist on local system and does exist on Drobo
			repoSlug="${1}"
			shift
			subcommandRemote "${repoSlug}"
			;;
		* )
			# Default: Blank or unknown subcommand, report error if unknown subcommand
			# Note: Lack of comment on same line as case, default action will not be displayed by usage or ls subcommand
			usage
			if [[ -n "${subcommand}" ]] ; then
				errorExit "ERROR: Unknown subcommand: ${subcommand}" 4
			fi
			;;
	esac
	return ${?}
}


usage () {
	# Description: Generate and display usage
	# References: Albing, C., JP Vossen. bash Idioms. O'Reilly. 2022.
	# Arguments:
	#   ${1} : (Optional) Search term
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	searchTerm="${1}"
	shift
	# Core actions
	(
		echo $( basename "${SELF}" ) 'Usage:'
		egrep '\)[[:space:]]+# ' "${SELF}" | tr -s '\t'
	) | grep "${searchTerm:-.}" | less
}


errorExit () {
	# Description: Output ${1} (error message) to stderr and exit with ${2} (error status).
	# Arguments:
	#   ${1} : Error message to write
	#   ${2} : (Optional) Error status to exit with
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	errorStatus=1
	errorMessage="${1}"
	shift
	# Core actions
	echo "${errorMessage}" >&2
	if [[ -n "${1}" ]] ; then
		errorStatus="${1}"
	fi
	cleanUpArtifacts
	exit "${errorStatus}"
}


warningReport () {
	# Description: Output ${1} (warning message) to stderr, but DO NOT exit.
	# Arguments:
	#   ${1} : Warning message to write
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	warningMessage="${1}"
	shift
	# Core actions
	echo "${warningMessage}" >&2
}


listNonBaseSubcommands () {
	# Description: Generate and display list of non-base subcommands
	# References: Albing, C., JP Vossen. bash Idioms. O'Reilly. 2022.
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	:
	# Core actions
	(
		echo $( basename "${SELF}" ) 'Subcommands:'
		egrep '\)[[:space:]]+# ' "${SELF}" | tr -d '\t'
	) | grep -v 'base[ ]subcommand' | less
}


isValidEnvironment () {
	# Description: Determines if environment is valid or not
	# Args:
	#   ${@} : Command line arguments
	# Return:
	#   0 : VALID   environment
	#   1 : INVALID environment
	# isInRangeInt 1 2 $#
	# if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
	# 	return 1
	# fi
	# if [[ "${1}" -eq "help" ]] ; then
	# 	return 0
	# fi
	# isInRangeInt 2 2 $#
	# if (( 0 != ${?} )) ; then  # Invalid number of command line arguments
	# 	return 1
	# fi
	isValidDirectoryName "${DROBO_REPOS_DIR_PATH}"
	if (( 0 != ${?} )) ; then  # Invalid directory name - $DROBO_REPOS_DIR_PATH from libDroboShellGit.sh
		return 1
	fi
	isValidDirectoryName "${1}"
	if (( 0 != ${?} )) ; then  # Invalid directory name - ${2} from caller
		return 1
	fi
	DROBO_GIT_DIR="${DROBO_REPOS_DIR_PATH}${1}"
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
}


subcommandClone () {
	# Description: Clone an existing repo from the Drobo to the local host
	# Args:
	#   ${1} : File system friendly name of repo to clone from the Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host and Drobo
	#   1 : ERROR:   Git repo NOT setup on local host, but repo     found on Drobo
	#   3 : ERROR:   Git repo NOT setup on local host, and repo NOT found on Drobo
	#   4 : ERROR:   Incorrect sub-command usage

	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	## Actions on Drobo
	echo "[on Drobo]"
	:  # Placeholder, syntactic NOP
	## Actions on local host
	echo "[on localhost]"
	droboGitClone "${1}"
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
	cd ${1}
	droboGitConfig origin
	if (( 0 != ${?} )) ; then  # ERROR: ...
		return 1
	fi
}


subcommandInit () {
	# Description: Initialize a new repo on the Drobo and clone to the local host
	# Args:
	#   ${1} : File system friendly name of repo to initialize on the Drobo and clone to local host
	# Return:
	#   0 : (normal) Git repo     setup on local host and Drobo
	#   1 : ERROR:   Git repo NOT setup on local host, but repo     setup on Drobo
	#   3 : ERROR:   Git repo NOT setup on local host, and repo NOT setup on Drobo
	#   4 : ERROR:   Incorrect sub-command usage

	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
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
	git init
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
	droboGitRemoteAddConfig origin
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
}


subcommandMirror () {
	# Description: Initialize a new repo on the Drobo as a remote to an existing repo on the local host, pushes existing repo to Drobo
	# Args:
	#   ${1} : File system friendly name of repo to initialize on the Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host and Drobo
	#   2 : ERROR:   Git repo     setup on local host, but repo NOT setup on Drobo
	#   3 : ERROR:   Git repo NOT setup on local host, and repo NOT setup on Drobo
	#   4 : ERROR:   Incorrect sub-command usage

	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	## Actions on Drobo
	echo "[on Drobo]"
	droboSSHgitInit ${1}
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 3
	fi
	## Actions on local host
	echo "[on localhost]"
	droboGitRemoteAddConfig ${DROBO_GIT_NAME}
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
	git push --all ${DROBO_GIT_NAME}
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 3
	fi
}


subcommandRemote () {
	# Description: ...

	# Set up working set
	:
	# Core actions
	:
}


droboSSHgitInit () {
	# Description: SSH to Drobo, execute droboGitServer.sh
	# Args:
	#   ${1} : File system friendly name of repo to initialize on the Drobo
	# Return:
	#   0 : (normal) Git repo     setup on Drobo
	#   2 : ERROR:   Git repo NOT setup on Drobo
	#   4 : ERROR:   Incorrect sub-command usage

	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	ssh ${DROBO_USERNAME}@${DROBO_NET_ID} "export PATH=${DROBO_ENV_PATH} && droboGitServer.sh init ${1}"
	case ${?} in
		# Normal return
		0 )
			;;
		# ERROR: ssh failed
		255 )
			echo "ERROR: ssh to Drobo failed" >&2
			return 2
			;;
		# ERROR: droboGitServer.sh failed
		* )
			echo "ERROR: droboGitServer.sh on Drobo failed, exit status: ${?}" >&2
			return 2
			;;
	esac
}


droboGitClone () {
	# Description: Clone repo on Drobo to local host using ssh
	# Args:
	#   ${1} : File system friendly name of repo to initialize on the Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host
	#   1 : ERROR:   Git repo NOT setup on local host
	#   4 : ERROR:   Incorrect sub-command usage

	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	git clone -u ${DROBO_GIT_PACK_DIR_PATH}/git-upload-pack ${DROBO_GIT_URL} ${1}
	if (( 0 != ${?} )) ; then  # ERROR: Failed to clone repo from Drobo
		echo "ERROR: Failed to clone repo from Drobo" >&2
		return 1
	fi
}


droboGitRemoteAddConfig () {
	# Description:
	# Args:
	#   ${1} : Name of remote in Git for Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host
	#   1 : ERROR:   Git repo NOT setup on local host
	#   4 : ERROR:   Incorrect sub-command usage

	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	git remote add ${1} ${DROBO_GIT_URL}
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
	droboGitConfig ${1}
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
}


droboGitConfig () {
	# Description:
	# Args:
	#   ${1} : Name of remote in Git for Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host
	#   1 : ERROR:   Git repo NOT setup on local host
	#   4 : ERROR:   Incorrect sub-command usage

	## Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	git config remote."${1}".uploadpack ${DROBO_GIT_PACK_DIR_PATH}/git-upload-pack && git config remote."${1}".receivepack ${DROBO_GIT_PACK_DIR_PATH}/git-receive-pack
	if (( 0 != ${?} )) ; then  # ERROR: Failed to configure repo on local host
		echo "ERROR: Failed to configure repo on local host" >&2
		return 1
	fi
}


# Call main()
main "${@}"
