#!/usr/bin/env bash


## NAME
##	droboGit.sh  Set up Git repo on local host and remote Drobo
##
## SYNOPSIS
##	droboGit.sh help
##
##	??? ...
##
## DESCRIPTION
##	Client side (on local host) script for setting up and linking Git repo on remote Drobo, and repo on local host.
##	Part of the droboShellScripts project.
##
##	Subcommands:
##
##	help     (base subcommand) Display help message, supports single term filtering.
##
##	manual   (base subcommand) Display this manual.
##
##	version  (base subcommand) Display version information.
##
##	list  List repositories on Drobo.
##
## EXPECTATIONS
##
##	- $DROBO_REPOS_DIR_PATH exists and user context has read, write, and execute permissions
##
## EXPERT
##	The following environment variables can be set to affect execution:
##
##	- reportError       : Defaults to "echo" if not set, command to use when reporting error messages
##	- reportWarning     : Defaults to "echo" if not set, command to use when reporting warning messages
##	- reportCaution     : Defaults to ":" if not set, command to use when reporting caution messages
##	- reportInformation : Defaults to ":" if not set, command to use when reporting information and completion messages
##	- reportTelemetry   : Defaults to ":" if not set, command to use when reporting telemetry messages
##	- reportDebug       : Defaults to ":" if not set, command to use when reporting debug messages
##
## EXIT STATUS
##	0  : (normal) On success
##	1+ : ERROR
##	2  : ERROR: Invalid usage
##
## DEPENDENCIES
##	echo(0|1) : Built-in or POSIX echo
##	egrep(1)  : POSIX egrep
##	grep(1)   : POSIX grep
##	less(1)   : GNU (common UNIX) less
##	sort(1)   : POSIX sort
##	ssh(1)    : RFC 4250 - RFC 4256
##	tr(1)     : POSIX tr
##
## DROBO DEPENDENCIES
##	- Drobo Dashboard Admin Account
##	- Drobo Apps > Bash
##	- Drobo Apps > Git SCM
##	- Drobo Apps > Dropbear
##
## AUTHORS
##	Drip.Flux.


# Save script name
SELF="${0}"
SEMVER_STRING="1.0.0-alpha.20261107001"  # See URL: https://semver.org/


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
	# Arguments:
	#   ${1} : Subcommand
	#   ${2} : File system friendly name of repo to create
	# Use cases (subcommands):
	#   help   : [1-2 args] ...
	#   clone  : [2 args] ...
	#   init   : [2 args] ...
	#   mirror : [2 args] ...
	#   remote : [2 args] ...
	# Return:
	#   0 : (normal) Git repo     setup on local host and Drobo
	#   1 : ERROR:   Git repo NOT setup on local host, but repo     setup on Drobo
	#   2 : ERROR:   Git repo     setup on local host, but repo NOT setup on Drobo
	#   3 : ERROR:   Git repo NOT setup on local host, and repo NOT setup on Drobo
	#   4 : ERROR:   Incorrect [subcommand] usage, or invalid environment

	# Set up working set
	set_up_environment
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
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
		help )     # (base subcommand) Display this help message, supports single term filtering.
			searchTerm="${1}"
			shift
			usage "${searchTerm}"
			;;
		manual )   # (base subcommand) Display full manual.
			manual
			;;
		version )  # (base subcommand) Display version information.
			version_info
			;;
		list )     # List repositories on Drobo.
			: list_drobo_repos
			;;
		clone )    # Clone repository that exists on Drobo but does not exist on local system.
			repoSlug="${1}"
			shift
			clone_drobo_repo "${repoSlug}"
			;;
		init )     # Initialize repository that does not exist on Drobo and does not exist on local system.
			repoSlug="${1}"
			shift
			subcommandInit "${repoSlug}"
			;;
		mirror )   # Mirror repository that does exist on local system but does not exist on Drobo.
			repoSlug="${1}"
			shift
			subcommandMirror "${repoSlug}"
			;;
		remote )   # Add Drobo as remote for repository that does exist on local system and does exist on Drobo.
			repoSlug="${1}"
			shift
			subcommandRemote "${repoSlug}"
			;;
		* )
			# Default: Blank or unknown subcommand, report error if unknown subcommand
			# Note: Lack of comment on same line as case, default action will not be displayed by usage or ls subcommand
			if [[ -z "${subcommand}" ]] ; then  # Blank subcommand
				usage
			else
				exit_error "ERROR: Unknown subcommand: ${subcommand}" 2
			fi
			;;
	esac
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


usage () {
	# Description: Generate and display usage
	# References:
	#   - Albing, C., JP Vossen. bash Idioms. O'Reilly. 2022.
	# Arguments:
	#   ${1} : (Optional) Search term
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	searchTerm="${1}"
	shift
	# Core actions
	(
		echo "${SELF##*/}" 'Usage:'
		egrep '[[:space:]]\)[[:space:]]+#[[:space:]]' "${SELF}" | tr -s '\t' | sort
	) | grep -i "${searchTerm:-.}" | less
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


manual () {
	# Description: Display full manual
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	# Developer Note: Ignore lines that incorporate "${SELF##*/}"
	grep '[#][#]' "${SELF}" | grep -v 'SELF' | less
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


version_info () {
	# Description: Output version information.
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	echo "${SELF##*/}" "${SEMVER_STRING}"
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


set_up_environment () {
	# Description: Set up environment.
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	# Core actions
	: ${reportError:=echo}
	: ${reportWarning:=echo}
	: ${reportCaution:=:}
	: ${reportInformation:=:}
	: ${reportTelemetry:=:}
	: ${reportDebug:=:}
	: ${TMPDIR:=/tmp}
}


exit_error () {
	# Description: Output ${1} (error message) to stderr and exit with ${2} (error status).
	# Arguments:
	#   ${1} : Error message to write.
	#   ${2} : (Optional) Error status to exit with.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	errorStatus=1
	errorMessage="${1}"
	shift
	# Core actions
	"${reportError}" '[!] ERROR:' "${errorMessage}" >&2
	if [[ -n "${1}" ]] ; then
		errorStatus="${1}"
	fi
	exit "${errorStatus}"
}


report_warning () {
	# Description: Output ${1} (warning message) to stderr as warning.
	# Arguments:
	#   ${1} : Warning message to write.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	warningMessage="${1}"
	shift
	# Core actions
	"${reportWarning}" '[!] WARNING:' "${warningMessage}" >&2
}


report_caution () {
	# Description: Output ${1} (caution message) to stderr as caution.
	# Arguments:
	#   ${1} : Caution message to write.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	cautionMessage="${1}"
	shift
	# Core actions
	"${reportCaution}" '[^] CAUTION:' "${cautionMessage}" >&2
}


report_information () {
	# Description: Output ${1} (information message) to stderr as information.
	# Arguments:
	#   ${1} : Information message to write.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	informationMessage="${1}"
	shift
	# Core actions
	"${reportInformation}" '[-] INFO:' "${informationMessage}" >&2
}


report_complete () {
	# Description: Output ${1} (completion message) to stderr as information.
	# Arguments:
	#   ${1} : Completion message to write.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	completionMessage="${1}"
	shift
	# Core actions
	"${reportInformation}" '[+] INFO:' "${completionMessage}" >&2
}


report_telemetry () {
	# Description: Output ${1} (telemetry message) to stderr as telemetry.
	# Arguments:
	#   ${1} : Telemetry message to write.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	telemetryMessage="${1}"
	shift
	# Core actions
	"${reportTelemetry}" '[.] TELEMETRY:' "${SELF##*/}::${telemetryMessage}" >&2
}


report_debug () {
	# Description: Output ${1} (debug message) to stderr as debug.
	# Arguments:
	#   ${1} : Debug message to write.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	debugMessage="${1}"
	shift
	# Core actions
	"${reportDebug}" '[.] DEBUG:' "${debugMessage}" >&2
}


isValidEnvironment () {
	# Description: Determines if environment is valid or not
	# Args:
	#   ${@} : Command line arguments
	# Return:
	#   0 : VALID   environment
	#   1 : INVALID environment

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
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
	isValidDroboName "${DROBO_GIT_NAME}"
	if (( 0 != ${?} )) ; then  # Invalid
		return 1
	fi
	isValidDroboNetID "${DROBO_NET_ID}"
	if (( 0 != ${?} )) ; then  # Invalid
		return 1
	fi
	isValidUsername "${DROBO_USERNAME}"
	if (( 0 != ${?} )) ; then  # Invalid
		return 1
	fi
	isValidProtocol "${DROBO_GIT_PROTOCOL}"
	if (( 0 != ${?} )) ; then  # Invalid
		return 1
	fi
	generateRepoURL
	if (( 0 != ${?} )) ; then  # Invalid
		return 1
	fi
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


clone_drobo_repo () {
	# Description: Clone an existing repo from the Drobo to the local host
	# Args:
	#   ${1} : File system friendly name of repo to clone from the Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host and Drobo
	#   1 : ERROR:   Git repo NOT setup on local host, but repo     found on Drobo
	#   3 : ERROR:   Git repo NOT setup on local host, and repo NOT found on Drobo
	#   4 : ERROR:   Incorrect sub-command usage

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	# Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	#  Actions on Drobo
	echo "[on Drobo]"
	:  # Placeholder, syntactic NOP
	#  Actions on local host
	echo "[on localhost]"
	droboGitClone "${1}"
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
	cd "${1}"
	droboGitConfig origin
	if (( 0 != ${?} )) ; then  # ERROR: ...
		return 1
	fi
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
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

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	# Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	# Actions on Drobo
	echo "[on Drobo]"
	droboSSHgitInit "${1}"
	if (( 0 != ${?} )) ; then  # ERROR: ...
		return 3
	fi
	# Actions on local host
	echo "[on localhost]"
	git init
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
	droboGitRemoteAddConfig origin
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
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

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	# Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	# Actions on Drobo
	echo "[on Drobo]"
	droboSSHgitInit "${1}"
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 3
	fi
	# Actions on local host
	echo "[on localhost]"
	droboGitRemoteAddConfig "${DROBO_GIT_NAME}"
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
	git push --all "${DROBO_GIT_NAME}"
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 3
	fi
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


subcommandRemote () {
	# Description: ...

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	:
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


droboSSHgitInit () {
	# Description: SSH to Drobo, execute droboGitServer.sh
	# Args:
	#   ${1} : File system friendly name of repo to initialize on the Drobo
	# Return:
	#   0 : (normal) Git repo     setup on Drobo
	#   2 : ERROR:   Git repo NOT setup on Drobo
	#   4 : ERROR:   Incorrect sub-command usage

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	# Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	ssh "${DROBO_USERNAME}@${DROBO_NET_ID}" "export PATH=${DROBO_ENV_PATH} && droboGitServer.sh init ${1}"
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
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


droboGitClone () {
	# Description: Clone repo on Drobo to local host using ssh
	# Args:
	#   ${1} : File system friendly name of repo to initialize on the Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host
	#   1 : ERROR:   Git repo NOT setup on local host
	#   4 : ERROR:   Incorrect sub-command usage

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	# Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	git clone -u "${DROBO_GIT_PACK_DIR_PATH}/git-upload-pack" "${DROBO_GIT_URL}" "${1}"
	if (( 0 != ${?} )) ; then  # ERROR: Failed to clone repo from Drobo
		echo "ERROR: Failed to clone repo from Drobo" >&2
		return 1
	fi
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


droboGitRemoteAddConfig () {
	# Description:
	# Args:
	#   ${1} : Name of remote in Git for Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host
	#   1 : ERROR:   Git repo NOT setup on local host
	#   4 : ERROR:   Incorrect sub-command usage

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	# Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	git remote add "${1}" "${DROBO_GIT_URL}"
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
	droboGitConfig "${1}"
	if (( 0 != ${?} )) ; then  # ERROR: Pass Back
		return 1
	fi
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


droboGitConfig () {
	# Description:
	# Args:
	#   ${1} : Name of remote in Git for Drobo
	# Return:
	#   0 : (normal) Git repo     setup on local host
	#   1 : ERROR:   Git repo NOT setup on local host
	#   4 : ERROR:   Incorrect sub-command usage

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	# Correct Usage
	isInRangeInt 1 1 $#
	if (( 0 != ${?} )) ; then  # Invalid number of arguments
		return 4
	fi
	git config "remote.${1}.uploadpack" "${DROBO_GIT_PACK_DIR_PATH}/git-upload-pack" && git config "remote.${1}.receivepack" "${DROBO_GIT_PACK_DIR_PATH}/git-receive-pack"
	if (( 0 != ${?} )) ; then  # ERROR: Failed to configure repo on local host
		echo "ERROR: Failed to configure repo on local host" >&2
		return 1
	fi
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


# Developer Note: This script supports running as a script like normal and sourcing as a library.
# 1. Change the below variable name to a unique ID for this script.
#    - Recommendation: Change "_THIS_" to the name of this scirpt
#    - E.g. ${source__THIS__as_library} --> ${source_droboGit_as_library}
# 2. Assign a value to the uniquely named variable in the script you want to source this library from.
#    - E.g. source_droboGit_as_library=y
# 3. Source this script in the other script referencing this script as a library
#    - E.g. source droboGit.sh
# NOTE: bash does not have the concept of namespaces, name collisions will overwrite previous assignments when sourced.
if [[ -z ${source_droboGit_as_library} ]] ; then
	main "${@}"
fi
