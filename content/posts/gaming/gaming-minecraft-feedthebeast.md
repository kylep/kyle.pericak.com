title: Private Minecraft Feed-The-Beast Server & Client Setup
description: Hosting a private modded mincraft server and connecting to it
slug: gaming-minecraft-feedthebeast
category: gaming
tags: minecraft
date: 2019-09-20
modified: 2019-10-11
status: published


This guide covers how I set up a dedicated modded Minecraft Feed The Beast
server on spare laptop so my wife and I could play together.

**NOTE**: Ubuntu 18.04 doesn't work at all. It uses a newer version of Java
which doesn't work with Minecfraft's launcher.

---

# Server Setup

## Make the VM

I'm just using a laptop with Windows 8.0 and Hyper-V for this. It has 16GB RAM,
4 Cores + Hyperthreading, and a 1TB SSD.

Here are the server VM specs I used:
- Operating System: Ubuntu 16.04 Server
- RAM: 12GB
- Disk: 200GB (Thin provisioned)

Also, set a static IP address.


## Download the Modded Server Code

Open your browser to [the mod site](https://www.curseforge.com/minecraft/modpacks/ftb-ultimate-reloaded)
and find the link to the [server files](https://www.feed-the-beast.com/projects/ftb-ultimate-reloaded/files).

You can download the server files from your browser and SCP it over or download
them to the server directly with wget:

```bash
mkdir -p ~/ftb
cd ~/ftb
wget https://media.forgecdn.net/files/2778/970/FTBUltimateReloadedServer_1.9.0.zip

```

Unzip the server file archive

```bash
apt-get update
apt-get install -y unzip
unzip FTBUltimateReloadedServer_1.9.0.zip
```


## Configure the Server

`vi settings.sh`

```bash
# Set the RAM to 10GB
export MAX_RAM="10240M"
```


## Install Java JRE

```bash
apt-get install -y default-jre
```


## Launch the Server

I like to console into the server and start a TMUX session, then SSH to it
and join that session to keep the server running. You can also just make a
systemd unit if you like.

From the ftb folder start the server interactively:
```bash
bash ~/ftb/ServerStart.sh
```


---

# Client Setup


## Preferred Option: MultiMC

This is now my prefered way of installing the client. It works offline, and is
strictly about launching Minecraft. Also it has some nice features like
a window that seems to `tail -f` the minecraft log.

1. Download [Multi-MC](https://multimc.org/), install, and launch it.
1. Click Add Instance
1. Choose FTB Legacy > FTB Ultimate Reloaded. Ok.
1. Wait for the download to finish
1. Double-click the new icon with the mod name
1. If prompted to go to the account manager, say yes
1. If not in the settings window, open it. Go to Java. Increase the RAM.
   It looks like 5120MB works well, with 512 for PermGem.
1. Close the settings.
1. Double-click on the installed mod to launch it


## Alternative Option: Twitch Client

*Note*: The twitch launcher is, IMO, bad. It refuses to go offline, shows you
tons of stuff you don't need, and is in general a pain to work with. Unless you
already use Twitch for other games or enjoy watching streamers, I suggest you
try MultiMC first.

From a Windows client OS, go to [twitch's download site](https://www.twitch.tv/downloads)
and download the **twitch app for windows**.

Run the installer. You might need to make a Twitch account if you don't have
one, which is a pain but they bought Curse so there's no real better way to
do this.

1. Log in. If you don't have an account, try MultiMC, then make one if it
   doesn't work for you.
1. At the top of the screen, go to Mods.
1. Click on Minecraft. If its not installed yet, its probably greyed out.
1. Click Install.
1. When the install is done you can go to "Browse FTB Modpacks" up top.
1. Click FTB Ultimate Reloaded
1. Click Install

