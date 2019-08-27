title: Network Jump Box / Bastion
description: X11 forwarding Chrome through SSH to access internal web endpoints
slug: x11-forwarding-ubuntu18
category: guides
date: 2019-08-19
modified: 2019-08-19
status: published

# Objective
Open Chrome on an Ubuntu Server VM deployed at a remote location.


# Configure Workstation (Macbook) SSH Settings for X11 Forwarding
If you're not using a macbook, this won't apply.


## Set XAuthLocation
Your workstation needs to allow X11 forwarding. Some brilliant update broke it
in Mac OS so you need to set the XAuthLocation for your workstation.

`vi /etc/ssh/ssh_config`
```bash
Host *
  SendEnv LANG LC_*
  XAuthLocation /usr/X11/bin/xauth
  ServerAliveInterval 60
  ForwardX11Timeout 596h
```

## Enable ForwardAgent and ForwardX11
My hostname was adc-bmc and its IP was 192.168.2.2. Alter this as needed.
On your workstation:

`vi ~/.ssh/config`
```bash
Host adc-bmc
  HostName 192.168.2.2
  ForwardAgent yes
  ForwardX11 yes
```


# Remotely Launch Graphical Apps with XWindows
One pain point I often have is forwarding the ports for a whole bunch of web
services and  IPMI/IDRAC/ILO/Whatever connections through my pivot server to my
workstation. Its really tedious, and having a web UI right on the jump server
can be really helpful.

To launch Chrome on the Ubuntu Server system, you need xinet. It can forward
the X11 session through your SSH session, rendering the browser on your
workstation.


## Install Chrome
You can use firefox or whatever instead. Chrome's install will fail due to
missing dependencies, but apt can sort it out.
```bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
apt-get install -f
dpkg -i google-chrome-stable_current_amd64.deb
```

## Install x11-apps for xeyes
These are mostly just for testing. Xeyes is kind of neat a good way to test
that the forwarding is working.
```
apt-get install -y x11-apps
```


# Launch Forwarded XWindows Session
## Open SSH with X11 Forwarding Enabled.
XWindows can be passed through SSH. Open a new terminal window and connect to
the server using the `-X` flag to enable X forwarding on the client.

The xeyes application is a nice little test.

```bash
ssh -X myuser@192.168.2.2 xeyes
```

If that works, try Chrome. The extra flags enable compression and use a faster
encryption algorithm. If they cause problems, just use `-X`.

```bash
ssh -XC -c chacha20-poly1305@openssh.com myuser@192.168.2.2 google-chrome
```



# Troubleshooting
## xauth:  timeout in locking authority file ~/.Xauthority

As your not-root user:
```
sudo rm ~/.Xauthority-c
sudo rm ~/.Xauthority-l
sudo rm -r ~/.Xauthority
mkdir ~/.Xauthority
chmod 0600 ~/.Xauthority
```

## $DISPLAY is Empty, No xauth program
On your mac, if you connect with `ssh -v -X ...` and you get an error line
saying `No xauth program`, then you need to edit your SSH config to specify
the xauth path.


## X11 connection rejected because of wrong authentication.
If you're on Mac, this can happen when you didn't set the `XAuthLocation` ssh
configuration.


# References
- [askubuntu.com - font resize](https://askubuntu.com/questions/173220/how-do-i-change-the-font-or-the-font-size-in-the-tty-console)
- [linuxize.com - Install chrome](https://linuxize.com/post/how-to-install-google-chrome-web-browser-on-ubuntu-18-04/)
- [github.com - x11 forwarding tshooting](https://github.com/dnschneid/crouton/issues/2676)
