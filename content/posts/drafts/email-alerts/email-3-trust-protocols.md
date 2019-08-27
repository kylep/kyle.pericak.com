title: Configure SPF, DKIM, & DMARK for Trusted Emails
slug: email-3-trust-protocols
category: guides
date: 2019-08-08
modified: 2019-08-08
Status: draft


[TOC]

---

## This post is part of a series
1. [Sending emails from an Ubuntu VM with Postfix](email-1-postfix-setup)
2. [Making an email alert Bash script + cron job](email-2-bash-cron)
3. **[Configuring SPF, DKIM, & DMARK for Trusted Emails](email-3-trust-protocols)**
4. [Sending emails using Python](email-4-python)
5. [Sending emails using AWS SES](email-5-aws-ses-api)
6. [Sending emails using GCP Mail API](email-6-gcp-mail-api)

---

# SPF

## What is SPF?
Sender Policy Framework

It's a DNS attribute you can assign to your domain name that lists which hosts
are expected to send emails for that domain.


## How to use SPF
There used to be a site with reference data at openspf.org but they ran out of
funding so it went offline. You can still get to its reference page from the
[WayBackMachine](http://web.archive.org/web/20190224184030/http://www.openspf.org/SPF_Record_Syntax),
though.


Go to your domain registrar's website and create a new entry for your domain.
In CloudFlare, you just go to the DNS page. Cloudflare supports both SPF and
TXT records, some registrars will only offer TXT. If yours offers both, use
both for this.

Create a record for the domain your emails will send from. For instance, if
your emails will send from noreply@alerts.example.com, create an entry for
alerts.example.com.

Check the above linked reference for other options such as using A records,
but here's an example of an SPF record stating that emails are expected from
the ip address 1.2.3.4. You can also use subnet masks if you own a range.

```
v=spf ip4:1.2.3.4 -all
```

Set your DNS record to the spf string, and that's it, you're done. Receiving
milters might check this and add a few points or whatever towards your sender's
trustworthiness.


### What's my sender's IP?
TO use the `ip4` attribute, you need to know the internet IP that your email
will reach the milter from, not the internal RFC1918 address.

If you're on a public cloud VM with a static public IP, that's it. If you're
using an internal VM behind a firewall, you should check with your network
admin since it might use a pool of IPs. Often though, everything just gets
NAT'd through a single outbound IP. You can get that from your server by
running this dig command:
```
dig +short myip.opendns.com @resolver1.opendns.com
```

---

# DKIM

## What is DKIM
Domain Keys Identified Mail

![It's like SPF with extra steps](https://i.imgflip.com/37oxj1.jpg)


Instead of just specifying an expected sender's source address in the source
domain's DNS record, DKIM uses a public key in a DNS record. That key is then
used to decrypt a token included in an email header sent from your postfix
service. This prevents people from spoofing your IP to pretend they're allowed
to send emails from your domain.

You need to install and configure some extra software alongside postfix to make
postfix sign your outbound emails.

## How to use DKIM

### Install DKIM
On Ubuntu 18.04, run this to install opendkim:
```
apt-get install -y opendkim opendkim-tools
```
### DKIM Config file
There's nothing in here that varies by environment, just copy and paste this
exact config.

`vi /etc/opendkim.conf`
```bash
Syslog                  yes
UMask                   007
Socket                  local:/var/run/opendkim/opendkim.sock
PidFile                 /var/run/opendkim/opendkim.pid
OversignHeaders         From
TrustAnchorFile         /usr/share/dns/root.key
UserID                  opendkim
AutoRestart             Yes
AutoRestartRate         10/1h
UMask                   002
Syslog                  yes
SyslogSuccess           Yes
LogWhy                  Yes
Canonicalization        relaxed/simple
ExternalIgnoreList      refile:/etc/opendkim/TrustedHosts
InternalHosts           refile:/etc/opendkim/TrustedHosts
KeyTable                refile:/etc/opendkim/KeyTable
SigningTable            refile:/etc/opendkim/SigningTable
Mode                    s
PidFile                 /var/run/opendkim/opendkim.pid
SignatureAlgorithm      rsa-sha256
UserID                  opendkim:opendkim
Socket                  inet:12301@localhost
```

### Create the SigningTable and KeyTable files
```bash
mkdir -p /etc/opendkim/keys
cd /etc/opendkim
chmod 0600 /etc/opendkim/keys
```

Now create the *signing table*:

`vi /etc/opendkim/signing.table`
```
*@example.com     sendonly._domainkey.example.com
```



# DMARK

# What is DMARK?

---

# References
- [linuxbabe.com postfix guide](https://www.linuxbabe.com/mail-server/postfix-send-only-multiple-domains-ubuntu)
