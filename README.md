## Aptik

Aptik is a tool for **migrating settings and data** from one Linux installation to another. It can be used while re-installing the operating system, and when moving to next release of a Linux distribution.

Aptik does not have options for encrypting the backups - *this is by design*. There is no encryption so that backup files can be edited by hand, and data can be restored manually if required. For security you can use an encrypted USB drive as the backup location and delete the data once you finish migrating to the new Linux installation.

For best results, the restore operation should be run on a **fresh Linux installation**. It can be run on an existing system but this is not recommended, and results will not be same as system from which backups were created.

Aptik supports **Debian, Ubuntu, Fedora, Arch and their derivatives**. Some features may be available only on some distributions. For example, migrating downloaded packages from package manager cache is supported only on Debian, Ubuntu and derivatives (which use apt); and on Arch and derivatives (which use pacman).

Aptik should only be used to migrate between two installations of **same distribution**. For example, you can migrate from Fedora 24 to Fedora 25, or from Ubuntu 17.04 to Ubuntu 17.10, but not from Fedora to Ubuntu. This is because package names and repositories vary between different distributions and cannot be migrated. You can migrate some items such as fonts, icons, themes, etc but you need to be careful and check for issues after you do the restore.

Aptik should only be used to migrate between two installations of **same architecture**. For example, you can migrate from 32-bit to 32-bit system, or from 64-bit to 64-bit system, but not from 32-bit to 64-bit. This is because package names and repositories vary between different architecures and cannot be migrated.

## Usage

Available commands and options are documented in the [User Manual](MANUAL.md)

## Features

- **Migrate Software Packages** - Saves a list of installed software packages to the selected backup location. Missing packages will be re-installed on the new system on restore. Supports Debian, Ubuntu, Fedora, Arch and derivatives. On Debian, Ubuntu and derivatives, the saved list includes only those packages that were installed by the user. The list does not include packages that came with the distribution or that were installed to satisfy dependencies. This minimizes the number of packages in the list and makes it easy to review and edit.
- **Migrate Software Repositories** - Saves a list of extra software repositories added to the system. The repos will be added to the new system on restore. Supports Debian, Ubuntu and derivatives. On Debian, Ubuntu and derivatives, both Launchpad PPAs and custom repositories (Google Chrome, Oracle VirtualBox, etc) are supported. Missing GPG keys for repositories will be imported on restore.
- **Migrate Downloaded Packages** - Saves downloaded packages from package manager cache to the selected backup location. Copies packages to package manager cache of the new system on restore. This saves time in downloading packages while re-installing software. Supports Debian, Ubuntu and derivatives (which use apt); and Arch and derivatives (which use pacman).
- **Migrate Fonts, Icons, Themes, Wallpapers** - Saves fonts, icons, themes and wallpapers to the selected backup location. Copies items to the new system on restore. Supports Debian, Ubuntu, Fedora, Arch and derivatives.
- **Migrate User Accounts, Groups and Group Memberships** - Saves a list of users, groups and group memberships to the selected backup location. Re-creates missing users, groups and group memberships on the new system on restore. Users accounts are migrated along with account passwords and account settings (such home directory path, password expiry rules, etc). Supports Debian, Ubuntu, Fedora, Arch and derivatives.
- **Migrate Home Directory Data** - Saves data from user home directories to selected backup location using TAR+GZip. Data is compressed before saving. Supports Debian, Ubuntu, Fedora, Arch and derivatives.
- **Migrate Device Mount Settings** - Saves and restores device mount settings in /etc/fstab and /etc/crypttab. Supports Debian, Ubuntu, Fedora, Arch and derivatives.
- **Migrate Cron Tasks** - Saves and restores cron jobs for each user. Supports Debian, Ubuntu, Fedora, Arch and derivatives.
- **Command-line Tool** - A command-line tool is available for people who prefer to work from a terminal. A separate package provides a GTK frontend for the command-line tool.
- **Dry Run Mode** - The command-line tool has a ``--dry-run`` switch which can be used to view actions that will be executed on restore without making changes to the system.
- **Donation Feature** - A complimentary feature is available for users who donate or contribute to this project. An option will be enabled to generate a single-file, stand-alone installer which can be executed on the new system for restoring the backups. This installer can be used as a stand-alone deployment package, which when executed on a new Linux installation, will transform it to the original system. 


## Installation

PPA and DEB files are available for Ubuntu and Ubuntu-based distributions. Binary installers are available for all Linux distributions.

**[Installation](https://github.com/teejee2008/aptik/wiki/Installation)**

## Donate

*Aptik* is a non-commercial application. I work on it during my free time based on my requirements and interest. If you wish to support this project, you can make a donation for $10 or more via PayPal. Your contributions will help keep the project alive and support future development.

**PayPal** ~ If you find this application useful and wish to say thanks, you can buy me a coffee by making a one-time donation with Paypal. 

[![](https://upload.wikimedia.org/wikipedia/commons/b/b5/PayPal.svg)](https://www.paypal.com/cgi-bin/webscr?business=teejeetech@gmail.com&cmd=_xclick&currency_code=USD&amount=10&item_name=Aptik%20Donation)  

**Patreon** ~ You can also sign up as a sponsor on Patreon.com. As a patron you will get access to beta releases of new applications that I'm working on. You will also get news and updates about new features that are not published elsewhere.

[![](https://2.bp.blogspot.com/-DNeWEUF2INM/WINUBAXAKUI/AAAAAAAAFmw/fTckfRrryy88pLyQGk5lJV0F0ESXeKrXwCLcB/s200/patreon.png)](https://www.patreon.com/bePatron?u=3059450)

**Bitcoin** ~ You can send bitcoins at this address or by scanning the QR code below:

```1Js5vfgmwKew4byF9unWacwAjBQVvZ3Fev```

![](https://4.bp.blogspot.com/-9hMyCacf0nc/WQ1p3dcdtwI/AAAAAAAAGgA/WC-4gbGFl7skTjNRZbl99EBsXeYfZDqpgCLcB/s1600/polo.png)
