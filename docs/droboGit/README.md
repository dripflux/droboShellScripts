# Drobo Git Scripts


**Table of Contents**

- [Overview](#overview)
  - [Design Philosophy](#design-philosophy)


[top](#drobo-git-scripts)

## Overview

Shell scripts for initializing and cloning Git repos on a Drobo from a host.


**Dependencies**

- Drobo Dashboard Administrator Account
- Drobo Apps > Git SCM
- Drobo Apps > Bash : `sh` (default shell on Drobo) does not support `export -f`
- ssh : ssh compliant on Drobo (Drobo Apps > Dropbear), ssh compliant on client


[top](#drobo-git-scripts)

### Design Philosophy

Since a Drobo is designed to be used as a file server not a development workstation the Git repos created by this code base are _bare_ repos.
There are four use cases the code base is designed to support.
The use cases represent the four possible starting states of whether the repo in question resides on the host or not, and on the Drobo or not.
The end state is that the repo in question resides on both the host and Drobo, and the host can push to and pull from the remote repo on the Drobo.

The below table depicts the four starting states and the associated Drobo shell script subcommand for the starting state.
To the extent possible the subcommand is mapped to the same Git subcommand.

|    |  Repo Not on Drobo  |  Repo on Drobo  |
|----|---------------------|-----------------|
|  Repo Not on Host  |  init    |  clone   |
|  Repo on Host      |  remote  |  mirror  |

- (init) initializing a new repo on the Drobo;
- (clone) cloning a repo that already exists on the Drobo; and
- (remote) creating a new repo on the Drobo from an already existing repo on the host

Those three use cases are mapped to the three `droboGit.sh` sub-commands: `init`, `clone`, and `remote` respectively.
The three sub-commands are simplified versions of the Git sub-commands: `init`, `clone`, `remote add`.
As such the implementations of the sub-commands follow the default Git versions without extra options.
That is `init` will initialize the repo on the local host in the current working directory, as _directory_ is an optional argument to `git init`.
But `clone` will clone the repo into a new directory on the local host named after the repo initialized on the Drobo, just as `git clone` would.

All of the subcommands implemented are initiated from the local host and use the Drobo as a remote.
Communications between the host and the Drobo are via SSH.

The Git repositories on the Drobo are created and managed using the Drobo Dashboard Administrator account.
Besides initial directory setup on the Drobo which needs `root` privilege to complete, the scripts on the local host and the Drobo *do not* need elevated privileges.
The Drobo Dashboard Administrator account is used, but `sudo` is not needed for or used in the scripts.

_Usage_

...


[top](#drobo-git-scripts)<span id="end">
