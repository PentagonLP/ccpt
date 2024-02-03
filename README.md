# ComputerCraft Package Tool (CCPT)
![projectstage](https://img.shields.io/badge/project%20stage-alpha-yellow)
![projectstage](https://img.shields.io/badge/version-1.0-yellow)
[![license](https://img.shields.io/github/license/hpf3/ccpt)](https://github.com/hpf3/ccpt/blob/main/LICENSE)
[![issues](https://img.shields.io/github/issues/hpf3/ccpt)](https://github.com/hpf3/ccpt/issues)<br>
[![contributors](https://img.shields.io/github/contributors/hpf3/ccpt)](https://github.com/hpf3/ccpt/graphs/contributors)
[![activity](https://img.shields.io/github/commit-activity/m/hpf3/ccpt)](https://github.com/hpf3/ccpt/commits/main)
[![lastcommit](https://img.shields.io/github/last-commit/hpf3/ccpt)](https://github.com/hpf3/ccpt/commits/main)<br>
![size](https://img.shields.io/github/languages/code-size/hpf3/ccpt)
![files](https://img.shields.io/github/directory-file-count/hpf3/ccpt)
![languages](https://img.shields.io/github/languages/count/hpf3/ccpt)<br>
### Package Tool for the Minecraft mod "*ComputerCraft/CC: Tweaked*"  
<br><img
    alt="missing image :("
    src="https://raw.githubusercontent.com/hpf3/ccpt/main/img/social-preview.gif"
/><br>

# NOTICE
I (hpf3) am unnoficially working on this project as i wanted something like it for personal use, but the original repo hasn't updated in a few years and there are changes i want to make.

Do not report issues with this version of the project to the original project.

original: https://github.com/PentagonLP/ccpt



## Features
The package tool is built after the Linux package tool '[apt/apt-get](https://salsa.debian.org/apt-team/apt)'. It has simular features as apt-get, but for ComputerCraft. You can **install a default set of packages** from online sources, or **register your own packages**. It deals with **dependencies** *(eg. Package A is dependend on package B, so if you install package A the tool will also install package B)* and it automaticly **checks for updates**; If updates are availible, you can **install them with one command**. This package tool was created to make all of that **as simple to do as possible**.<br>

At the moment, the list of default packages is very small. **If you are a developer and you want to register your own program, please read the '[How to apply for the default package list for one of your packages](https://github.com/hpf3/ccpt/wiki/How-to-apply-for-the-default-package-list-for-one-of-your-packages)' wiki article.**
## How to install 
The installer is hosted on [pastebin.com](https://pastebin.com). Therefore, you can install the tool with one command:
```
wget run https://raw.githubusercontent.com/hpf3/ccpt/main/ccptinstall.lua
```
 

Alternativly, you can manually download the [ccptinstall.lua](https://github.com/hpf3/ccpt/blob/main/ccptinstall.lua)-file, put it in your computers working directory and execute it.
## How to use
This program is a one-command-program. To use it, type:
```
ccpt <action>
```
The following actions are possible:  

### **1. Reload package data and search for updates**  
```
ccpt update
```
This fetches the list of default packages and properties of all packages, local packages included, from the internet and stores them localy.  


*The Output should look something like this:*
<br><img
    alt="missing image :("
    src="https://raw.githubusercontent.com/hpf3/ccpt/main/img/ccpt_update.png"
/><br>

### **2. Install a package**
```
ccpt install <packageid>
```
This installes the package with the id <packageid>, including all the packages it depends on.  
 
 
*The Output should look something like this:*
<br><img
    alt="missing image :("
    src="https://raw.githubusercontent.com/hpf3/ccpt/main/img/ccpt_install.png"
/><br>
 
### **3. Update all packages**  
```
ccpt upgrade
```
This updates all packages. If a package needs a new dependency after an update or an updated version of a dependency, the package it depends on will be installed or updated.  
 
 
*The Output should look something like this:*
<br><img
    alt="missing image :("
    src="https://raw.githubusercontent.com/hpf3/ccpt/main/img/ccpt_upgrade.png"
/><br>

### **4. Uninstall a package**  
```
ccpt uninstall <packageid>
```
This uninstalles the package with the given ID and all packages that depend on said package.  
 
 
*The Output should look something like this:*
<br><img
    alt="missing image :("
    src="https://raw.githubusercontent.com/hpf3/ccpt/main/img/ccpt_uninstall.png"
/><br>

### **5. Add a local/custom package**
```
ccpt add <packageid> <packageinfoURL>
```
This adds a custom package to the local list. You have to run 'ccpt update' though for it to be able to be installed/changed.  
 
 
*The Output should look something like this:*
<br><img
    alt="missing image :("
    src="https://raw.githubusercontent.com/hpf3/ccpt/main/img/ccpt_add.png"
/><br>

### **6. Remove a local/custom package**
```
ccpt remove <packageid>
```
This removes a custom package from the local list. You have to run 'ccpt update' though for it to be removed from the 'able to update/remove'-list.  
 
 
*The Output should look something like this:*
<br><img
    alt="missing image :("
    src="https://raw.githubusercontent.com/hpf3/ccpt/main/img/ccpt_remove.png"
/><br>

### **7. List all installed and able to install packages**
```
ccpt list
```
This lists name, their install status and wether they have availible updates of all installed and able to install packages.  

 
*The Output should look something like this:*
<br><img
    alt="missing image :("
    src="https://raw.githubusercontent.com/hpf3/ccpt/main/img/ccpt_list.png"
/><br>

### **8. Get info about a specific package**
```
ccpt info <packageid>
```
This prints name, author, description, website (if given), installation type, installed and newest version of a given package.  

 
*The Output should look something like this:*
<br><img
    alt="missing image :("
    src="https://raw.githubusercontent.com/hpf3/ccpt/main/img/ccpt_info.png"
/><br>

### **9. Display help**
```
ccpt help
```
This prints all availible actions for the 'ccpt' command.  
 
*The Output should look something like this:*
<br><img
    alt="missing image :("
    src="https://raw.githubusercontent.com/hpf3/ccpt/main/img/ccpt_help.png"
/><br>

### **10. Display current 'ccpt'-version**
```
ccpt version
```
This prints the installed version of ccpt.  
 
*The Output should look something like this:*
<br><img
    alt="missing image :("
    src="https://raw.githubusercontent.com/hpf3/ccpt/main/img/ccpt_version.png"
/><br>
## How to create your own package
Take a look in our Wiki: [How to create your own package](https://github.com/hpf3/ccpt/wiki/Create-your-own-package)
## Changelog
 Nothing here yet, we are still on 1.0 :)
## Last words
Well, that's about it! Thanks for using this package tool. It would be awsome if we could build a useful collection of packages over time.  
As always, please keep in mind that my first language is not english. There are defnitly some spelling/language-related mistakes in this repository. If you find one, please create an issue so I can fix them.  
Also, I'm still very new to Github. If you find anything I can do better, and there definitly is as I don't know all the features of Github yet, please do also create an issue.  
Anyways, thanks for reading all this!  
~PentagonLP
