title: Transfer Domain from Godaddy to Cloudflare
slug: dns-xfer-godaddy-cloudflare
category: guides
date: 2019-08-25
modified: 2019-08-25
Status: draft

# Objective
I owned some domain names that used godaddy.com as their registrar. With
Godaddy it takes **forever** for changes to propogate, which can be a real
problem when you need to update TXT records.

Cloudflare is awesome in that they're really affordable for domains, have
really nice CDN capabilities, don't charge you for "protection", and their DNS
changes replicate super fast.

In this guide, I move my pericak.com domain from Godaddy to Cloudflare.

# Steps
## Unlock the Domain
1. Log into Godaddy
2. Go to [My Domains](https://dcc.godaddy.com/domains/) and select your domain
3. Click "Edit" next to `Domain lock: On` to show the slider. Set it to "off".

## Get your transfer authorization code
1. Log into Godaddy
2. Go to [My Domains](https://dcc.godaddy.com/domains/) and select your domain
3. Click 'Transfer domain away from GoDaddy'
4. Continue with transfer
5. Skip whatever annoying ads they give you
6. Go to your email and get your registration code

## Transfer the Domain to Cloudflare
If you haven't added your site yet, add it now in cloudflare. You need to add
the nameserver settings too before you can transfer it. This tripped me up,
since I hadn't redirected the nameservers from godaddy's default ones to
CloudFlares yet.

1. From cloudflare's dashboard, go to Domain Registration
2. It should let you choose your domain here. If it says there are none
   available, you haven't set up your existing domain with them yet.
3. Enter your auth code, click Confirm Authorization Codes
4. Fill out the contact info, Confirm and Finalize Transfer

That's it, your domain is now transfered to CloudFlare

# References
- [cloudlfare guide](https://developers.cloudflare.com/registrar/transfer-instructions/godaddy/)
- [godaddy unlock for xfer](https://ca.godaddy.com/help/unlock-my-domain-for-transfer-410)

