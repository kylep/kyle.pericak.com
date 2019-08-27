title: Send Emails from an Ubuntu VM with Postfix
slug: email-1-postfix-setup
category: guides
date: 2019-08-02
modified: 2019-08-02
Status: draft


[TOC]

---

This post is part of a series

1. **[Sending emails from an Ubuntu VM with Postfix](email-1-postfix-setup)**
2. [Email Alert Script for Scheduled Pings with Bash and Cron](email-2-bash-cron)
3. [Configuring SPF, DKIM, & DMARK for Trusted Emails](email-3-trust-protocols)
4. [Sending emails using Python](email-4-python)
5. [Sending emails using AWS SES](email-5-aws-ses-api)
6. [Sending emails using GCP Mail API](email-6-gcp-mail-api)

---

# Objective
In order to send emails from your own VM you need a mail server. In my case
this was needed so I could send alert emails when a VPN went down. Here's how
to configure Postfix as that mail server.

## About this guide
- Covers how to configure a stand-alone send-only mail server
- No mail relay required
- Mail will be sent by Postfix service, installed on  Ubuntu 18.04
- Emails will come from noreply@alerts.example.com




# Create a send-only mail server with Postfix

# Find your external IP address
Many VMs use NAT to accesss the internet. To check your external IP address,
execute:
```
dig +short myip.opendns.com @resolver1.opendns.com
```
Below, the output of this command will be used as `<ext_ip>`

If you have a static public IP address you can use it as `<ext_ip>`


## Set your hostname to an FQDN in /etc/hosts
Lets say that your mail will come from a server named cron.alerts.example.com.

`vi /etc/hosts`
```
127.0.0.1 alerts.example.com
<ext_ip>  alerts.example.com
```


## Install postfix
This is the software that manages your mail queue and handles SMTP.
```
apt-get install -y postfix mailutils
```
If it asks you which type of server to install, select Internet Site.
Give it an FQDN when prompted. If you will be sending emails from
noreply@alerts.example.com, enter `alerts.example.com`.


## Configure Postfix
Here's a config that's worked for me. Be sure to change the myhostname field.



`vi /etc/postfix/main.cf`
```
myhostname = alerts.example.com

smtpd_banner = $myhostname ESMTP $mail_name (Ubuntu)
biff = no
append_dot_mydomain = no
readme_directory = no
smtpd_tls_cert_file = /etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file = /etc/ssl/private/ssl-cert-snakeoil.key
smtpd_use_tls = yes
smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
mydestination = $myhostname, 63ec22ec9fc1, localhost.localdomain, , localhost
relayhost =
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = loopback-only
inet_protocols = all
```

Once configured, restart postfix
```
systemctl restart postfix
```


## Send a test email
echo "Test alert please ignore" | mail -a "FROM:noreply@alerts.example.com" -s "Test alert" kyle@example.com



# Troubleshooting
Often emails don't go through. There are lots of reasons that can happen.


## Check for & remove mail stuck in the queue
Show the mail queue. It might tell you the error if the email is there.
```
mailq
```

If you've got a scheduled job that is adding emails, it can fill the queue up
and make you look like a spammer. Some mail servers will rate limit a sender,
especially if they haven't set up mechanisms by which they can be trusted.


To remove items from the mail queue by ID, run
```
# If you don't pass <ID> it will delete the all.
postsuper -d <ID>
```

### Mail is stuck in the queue!
This can happen for a ton of reasons. Here's how to deal with a few.

Check out [The SPF, DKIM, and DMARK guide](#TODO)

#### Add an SPF DNS Record
*NOTE:* This didn't help for me, and I might have done it wrong!

Go to your DNS provider and create a new SPF record. I used cloudflare, so I
made both an SPF record and a TXT record. They looked like this, IP redacted.
Replace <IP ADDRESS> with the IP of your agent sending mail.
```
v=spf1 ip4:<IP ADDRESS> ~all
```

#### Install & Configure DKIM
This is an application that gets installed alongside postfix.
```
apt-get install opendkim opendkim-tools
```

`vi /etc/opendkim.conf`
```
# Initial Config
Syslog                  yes
UMask                   007
Socket                  local:/var/run/opendkim/opendkim.sock
PidFile               /var/run/opendkim/opendkim.pid
OversignHeaders         From
TrustAnchorFile       /usr/share/dns/root.key
UserID                opendkim

# Suggested config from DigitalOcean:
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
Mode                    sv
PidFile                 /var/run/opendkim/opendkim.pid
SignatureAlgorithm      rsa-sha256
UserID                  opendkim:opendkim
Socket                  inet:12301@localhost
```

`vi /etc/default/opendkim`
Add this SOCKET line to the end, even if there's already a SOCKET defined.
```
SOCKET="inet:12301@localhost"
```




&nbsp;

### Outlook is blocking your emails
If you get a 500 error from outlook.\*, it could need a connector or a rule
exception for the filter. I haven't tested the connector.
 - [Disable the spam filter](https://docs.sophos.com/central/Customer/help/en-us/central/Customer/tasks/bypassingexchange.html)
 - [Use a connector (not tested)](https://docs.microsoft.com/en-us/exchange/mail-flow-best-practices/use-connectors-to-configure-mail-flow/set-up-connectors-to-route-mail)


# Next Up
Check out how to create a scheduled job that watches for ping responses and
uses this postfix server to send emails in my next post,
[Email Alert Script for Scheduled Pings with Bash and Cron](email-2-bash-cron)


# Other References
- [Postfix install guide from Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-16-04)
- [Postfix setup guide from hostadvice.com](https://hostadvice.com/how-to/how-to-setup-postfix-as-send-only-mail-server-on-an-ubuntu-18-04-dedicated-server-or-vps/)
- [Basic Postfix config referece](http://www.postfix.org/BASIC_CONFIGURATION_README.html)
- [Detailed Postfix config docs](http://www.postfix.org/postconf.5.html)
- [Whats My IP from Curl](https://www.cyberciti.biz/faq/how-to-find-my-public-ip-address-from-command-line-on-a-linux/)
- [5 ways to send email from cli](https://tecadmin.net/ways-to-send-email-from-linux-command-line/)
- [DigitalOcean DKIM guide](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-dkim-with-postfix-on-debian-wheezy)
