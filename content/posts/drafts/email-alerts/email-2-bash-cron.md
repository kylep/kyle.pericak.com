title: Email Alert Script for Scheduled Pings with Bash and Cron
slug: email-2-bash-cron
category: guides
date: 2019-08-08
modified: 2019-08-08
Status: draft


## This post is part of a series
1. [Sending emails from an Ubuntu VM with Postfix](email-1-postfix-setup)
2. **[Making an email alert Bash script + cron job](email-2-bash-cron)**
3. [Configuring SPF, DKIM, & DMARK for trusted emails](email-3-trust-protocols)
4. [Sending emails using Python](email-4-python)
5. [Sending emails using AWS SES](email-5-aws-ses-api)
6. [Sending emails using GCP Mail API](email-6-gcp-mail-api)


# Objective
Create a bash script that runs every minute to send an email when a ping fails.
You could use [Pingdom](https://www.pingdom.com/) but there's no need to pay
someone else if you have compute resources available. Also, this works from
inside your local network, so it can ping [RFC1918](https://tools.ietf.org/html/rfc1918)
addresses.

This script watches for ICMP (ping) availability.
You can replace the ping command with a netcat call to watch a port,
or run whatever other check you like.

## About this guide
- Create a script to send an email alert when a ping fails
- Add a cooldown so it sends max 1 email per hour
- Use a pre-installed postfix send-only service
- Emails send from noreply@alerts.example.com
- Emails send to alerts@example.com

&nbsp;

# Building the Alert Tool

## Test the mail command
Emails in this script will send using the `mail` command. Make sure it works
before continuing. If the email doesn't send, check my previous post
[here](#TODO).

```bash
echo "Test alert please ignore" | mail \
    -a "FROM:noreply@alerts.example.com" \
    -s "Test alert" \
    alerts@example.com
```

## Create the bash script
Create a directory to place the script. I'm writing this script for
[Breqwatr](https://www.breqwatr.com), but you can use any path.

```bash
mkdir -p - /etc/breqwatr && cd /etc/breqwatr
touch ping_alert.sh
chmod +x ping_alert.sh
```

Create the script:

`vi ping_alert.sh`
```bash
#!/usr/bin/env bash

# Positional arguments. If debug is set to '1', debug will echo
target_ip=$1
debug_enabled=$2

# debug function for troubleshooting
function debug () {
    if [[ "$debug_enabled" == "1" ]]; then
        echo $1
    fi
}

token_file='/etc/breqwatr/.email_sent'
sent_recently=false
now_ts=$(date +%s)
if [ -f $token_file ]; then
    file_ts=$(cat $token_file)
    hour_in_seconds=3600
    hour_from_file_ts=$(($file_ts+$hour_in_seconds))
    if [[ $now_ts -le $hour_from_file_ts ]]; then
        sent_recently=true
    fi
fi

if [[ $sent_recently == true ]]; then
    debug "sent recently, exiting. Check $token_file"
    exit
fi

# Ping the target IP and collect the return code
debug "Pigning $target_ip..."
ping -c 1 $target_ip >/dev/null
if [[ $? == 0 ]]; then
    debug "ping ok, exiting"
    exit
fi


debug "Sending warning email"
msg="Warning: Ping to IP $target_ip failed."
echo $msg | mail \
    -a  "FROM:noreply@alert.example.com" \
    -s "Test alert" \
    alerts@example.com

debug "Writing new timestamp $now_ts"
# Write the new timestamp
echo $now_ts > $token_file
```

Give the script a test run against a valid and invalid IP. It should send an
email for the invalid IP but not the valid one.

```
# test that should pass
/etc/breqwatr/ping_alert.sh 1.1.1.1
# test that should fail
/etc/breqwatr/ping_alert.sh 10.2.3.4
```

## Create cron job
We'll run this script every minute.
This example will ping [Cloudflare's DNS](https://new.blog.cloudflare.com/announcing-1111/),
be sure to replace the IP with one that you actually watch to watch.

`vi /etc/crontab`
```
# Keep whatever is currently there
*  *    * * *   root    /etc/breqwatr/ping_alert.sh 1.1.1.1 0 | tee -a /var/log/ping_alert.log
```

### Restart Cron to apply the changes
```
systemctl restart cron
```


# Next Up
Now, assuming your emails aren't being blocked as spam, your alert system is
ready to go!

To help ensure that your emails don't get marked as spam,
check out my next post, [Configuring SPF, DKIM, & DMARK for trusted emails](email-3-trust-protocols).
SPF, DKIM, and DMARK can help receiving mail filters
("[milters](https://en.wikipedia.org/wiki/Milter)") trust the mail that your
postfix service sends.
