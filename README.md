# Drobo Shell Scripts

Shell scripts for automating various tasks on a Drobo or from a remote host communicating with the Drobo.

## General Design Philosophy

Design Philosophy Summary:
- Drobo's are designed to be SOHO file servers
  - Drobo's are not intended to be used for heavy computation
  - Drobo's are not intended to be used as development workstations
- Apply [secure design principles](https://web.mit.edu/Saltzer/www/publications/protection/Basic.html)
  - Apply Priciple of Least Privilege &mdash; don't elevate to `root` when you don't need to

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
- Drobo App > Git SCM
- sh : default sh on Drobo, sh compliant on client
- ssh : ssh compliant on Drobo (Drobo App > Dropbear), ssh compliant on client

*Design Philosophy*

The Git repos created on the Drobo are *bare* repos, this aligns with a Drobo being designed to be used as a file server not development workstations.
Similarly, there are only three Git simplified sub commands implemented: `init`, `clone`, `remote add`.

All of the commands implemented are initiated from the local host and use the Drobo as a remote.
Communications between the host and the Drobo are via SSH.

The Git repositories on the Drobo are created and managed using the Drobo Dashboard Administrator account.
Besides initial directory setup on the Drobo which needs `root` privilege to complete, the scripts on the host and the Drobo do not need elevated privileges.
The Drobo Dashboard Administrator account is used, but `sudo` is not needed for or used in the scripts.
