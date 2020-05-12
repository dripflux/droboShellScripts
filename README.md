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
In fact, the Drobo Dashboard administrator account is the *only* account that is setup in the underlying Linux OS, non-administrator accounts created in the Drobo Dashboard are not setup in the underlying Linus OS.
The administrator account does have super-user access via `sudo`; i.e. the administrator account is in `sudoers`.
To that extent the scripts

## Repo Tree

```
.
??? README.md
??? docs
?   ??? droboGitShellScripts.drawio
??? droboGit.sh
??? droboGitServer.sh
??? libDroboGit.sh
```

## Sub Projects

- Drobo Git Scripts
