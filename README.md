# Drobo Shell Scripts

Shell scripts for automating various tasks on a Drobo or from a remote host communicating with the Drobo.

## General Design Philosophy

Design Philosophy Summary:
- Drobo's are designed to be SOHO file servers
  - Drobo's are not intended to be used for heavy computation
  - Drobo's are not intended to be used as development workstations
- Apply [secure design principles](https://web.mit.edu/Saltzer/www/publications/protection/Basic.html)
  - Apply Principle of Least Privilege &mdash; don't elevate to `root` when you don't need to

Drobo products are targeted for small office, home office, and individual professionals (<cite>[Drobo](https://www.drobo.com/), retrieved 11 May 2020</cite>).
Drobo's are designed to be file servers, specifically SMB.
Drobo's are embedded Linux devices, and as such support other file exchange and networking protocols, but many of which are provided (available) as 3rd party add-ons that only receive community support.

From an IT administration view point the customer demographics, marketing material, and Drobo Dashboard design there is an assumption that administrator tasks are performed by a single individual, or a small IT team.
To that extent, a number of users on the [Drobo Forums](https://drobocommunity.m-ize.com/) have noted that the only UNIX account that persists after a reboot or power cycle is the administrator account setup via in the Drobo Dashboard.
In fact, the Drobo Dashboard administrator account is the *only* account that is setup in the underlying Linux OS, non-administrator accounts created in the Drobo Dashboard are not setup in the underlying Linux OS.
The administrator account does have super-user access via `sudo`; i.e. the administrator account is in `sudoers`.
To that extent the scripts designed here minimize the elevating to `root` to the fullest extent possible.

## Repo Tree

```
.
|-- docs
|   \-- droboGitShellScripts.drawio
|-- README.md
|-- droboGit.sh
|-- droboGitServer.sh
\-- libDroboGit.sh
```

## Sub Projects

- Drobo Git Scripts

### Drobo Git Scripts

*Synopsis*

Shell scripts for initializing and cloning Git repos on a Drobo from a host.

Dependencies:

- Drobo Dashboard Administrator Account
- Drobo Apps > Git SCM
- Drobo Apps > Bash : `sh` (default shell on Drobo) does not support `export -f`
- ssh : ssh compliant on Drobo (Drobo Apps > Dropbear), ssh compliant on client

*Design Philosophy*

Since a Drobo is designed to be used as a file server not a development workstation the Git repos created by this code base are *bare* repos.
There are three use cases the code base is designed tp support:

- (init) initializing a new repo on the Drobo;
- (clone) cloning a repo that already exists on the Drobo; and
- (remote) creating a new repo on the Drobo from an already existing repo on the host

Those three use cases are mapped to the three `droboGit.sh` sub-commands: `init`, `clone`, and `remote` respectively.
The three sub-commands are simplified versions of the Git sub-commands: `init`, `clone`, `remote add`.
As such the implementations of the sub-commands follow the default Git versions without extra options.
That is `init` will initialize the repo on the local host in the current working directory, as *directory* is an optional argument to `git init`.
But `clone` will clone the repo into a new directory on the local host named after the repo initialized on the Drobo, just as `git clone` would.

All of the sub-commands implemented are initiated from the local host and use the Drobo as a remote.
Communications between the host and the Drobo are via SSH.

The Git repositories on the Drobo are created and managed using the Drobo Dashboard Administrator account.
Besides initial directory setup on the Drobo which needs `root` privilege to complete, the scripts on the local host and the Drobo *do not* need elevated privileges.
The Drobo Dashboard Administrator account is used, but `sudo` is not needed for or used in the scripts.

*Usage*

...
