title: Connecting Ubuntu 18.04 to WPA Wifi from CLI
slug: ubuntu-bionic-wifi
category: operations
tags: ubuntu, wifi
date: 2019-08-19
modified: 2019-08-19
Status: published

# Setup
This setup was done on an [Intel Nuc](https://www.intel.ca/content/www/ca/en/products/boards-kits/nuc.html).

The Nuc is running Ubuntu Server 18.04 Bionic, CLI only. It has a wired
connection to a DHCP-enabled home router initially, but will use wireless
internet after this in finished


# Find and Start the Wireless Device
```bash
ip link
```
Mine was called `wlp2s0`. Start it:
```bash
ip link set dev wlp2s0 up
```


---


# Install wireless software

Ubuntu server doesn't ship with the required packages to connect to wifi. This
is kind of a catch-22, so you need a wired connection to follow this guide.
You could also download the debs from another server but I won't be covering
that.

I'm pretty sure that it can connect to WEP without this, and its just the
newer WPA2 networks that basically everyone is using that need this.

```bash
apt-get install wireless-tools wpasupplicant
```

# Scan for SSIDs
The `iwlist` command can also give you other information about the network if
you don't pipe its output to grep, but it's pretty verbose.
```bash
iwlist wlp2s0 scanning | grep -ie ssid
```


# Join the Wifi Network with Netplan
You can use various commands to interactively connect to the network, but I
want this connection to come up with the NUC. Netplan is the new tool used to
configure networks since Ubuntu's Bionic stable release. Here's the netplan
config I used. You can see the wired connection in there too, it doesn't need
to be there once this is finished.

Be sure to replace "`MySSID`" and "`My Password`" with your own.

`vi /etc/netplan/01-netcfg.yaml`
```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s25:
      dhcp4: yes
  wifis:
    wlp2s0:
      dhcp4: yes
      access-points:
        "MySSID":
          password: "My Password"
```

Then apply the changes.
```
netplan try
```

You should have an IP address now in `ifconfig`. For some reason I didn't get
one right away, so I forced the DHCP request like this:
```
dhclient wlp2s0 -v
```

After that, you can connect to the wireless IP and don't need the wired one.

# Reference Links
- [AskUbuntu post about wpasupplicant](https://askubuntu.com/questions/138472/how-do-i-connect-to-a-wpa-wifi-network-using-the-command-line)
- [Ubuntuforums.org netplan post](https://ubuntuforums.org/showthread.php?t=2392154)
