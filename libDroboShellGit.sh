#!/usr/bin/env sh

# Author: Drip.Flux
# Description: Library for common routines related to Drobo Git SCM.
#   Intended to be sourced by other shell scripts.
# Dependencies:
#   - Drobo Dashboard Admin Account
#   - Drobo App: Git SCM
#   - sh: default sh on Drobo, sh compliant on client
#   - ssh: ssh compliant on Drobo (Drobo App: Dropbear), ssh compliant on client

# Declare Global Variables
## Personalize for User's Drobo
source droboID.sh  # Contains Drobo system and user identification, not part of repo, expected to be in $PATH
# Expect following variables to be assigned in droboID.sh
# - DROBO_GIT_NAME : Name to use as remote for Git; i.e. git remote
# - DROBO_NET_ID : Network identifier of Drobo, IP address or hostname
# - DROBO_USERNAME : Username on Drobo to authenticate as for Git commands, typically the Admin (Administrator) user from Drobo Dashboard
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
}

function isValidDirectoryName () {
	# Description: Determines if ${1} is a valid directory name or not
	# Args:
	#   ${1} : Directory name to validate
	# Return:
	#   0 : VALID   Directory Name
	#   1 : INVALID Directroy Name
	#   2 : ERROR: Incorrect Usage
}

function isValidDroboName () {
	# Description: Determines if ${1} is a valid Drobo Name or not
	# Args:
	#   ${1} : Drobo name to validate
	# Return:
	#   0 : VALID   Drobo Name
	#   1 : INVALID Drobo Name
	#   2 : ERROR: Incorrect Usage
}

function isValidProtocol () {
	# Description: Determines if ${1} is a valid Git + Drobo protocol or not
	# Args:
	#   0 : VALID   Protocol
	#   1 : INVALID Protocol
	#   2 : ERROR: Incorrect Usage
}

function isValidUsername () {
	# Description: Determines if ${1} is a valid username or not
	# Args:
	#   ${1} : Username to validate
	# Return:
	#   0 : VALID   Username
	#   1 : INVALID Username
	#   2 : ERROR: Incorrect Usage
}
