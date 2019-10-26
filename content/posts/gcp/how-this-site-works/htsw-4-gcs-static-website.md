title: Hosting a Static Website on Google Cloud Storage
slug: htsw-4-gcs-static-website
series: how-this-site-works
category: gcp
tags: Pelican,GCP
date: 2019-08-04
modified: 2019-08-04
status: published

---

Google Cloud Storage has a feature where storage buckets can be assigned a
domain name and used as a cost effective web server. That's how this site is
being hosted.

---


This guide is part of a series

1. [Building a Static Blog Site with Pelican and GCP](/htsw-1-intro.html)
1. [Build a pelican Docker image in the Google Container Registry](/htsw-2-pelican-image-gcr.html)
1. [How to write Pelican blog content files](/htsw-3-write-pelican-post.html)
1. **[Hosting a Static Website on Google Cloud Storage](/htsw-4-gcs-static-website.html)**
1. [Automatically rebuilding the site with Google Cloud-Build](/htsw-5-cloud-build-static-site.html)


---


# Requirements
- `gsutil` must be installed and configured for your GCP project
- The site's content and Pelican image must already be built
    - The output/ directory of the content repository must be populated

# Add the Domain to Google Search Console

A DNS TXT record containing a special string needs to be assigned to the domain
name that will be applied to the storage bucket. This is used to confirm
ownership of the domain.

**Note:** I had a really hard time doing this with GoDaddy. The TXT change
would not propagate even after over 24 hours. I transferred my domain to
[CloudFlare](https://cloudflare.com/). Their updates apply basically right
away!

- [How I transferred the domain from GoDaddy to CloudFlare](/dns-xfer-godaddy-cloudflare.html).

**Steps to add the domain to the search console:**

1. Open the [Google Search Console](https://search.google.com/search-console/welcome)
1. Enter your domain name
1. Copy the TXT record they gave you and apply it to your domain. In CloudFlare
   you go to your site, click DNS, Add Record, TXT. For kyle.pericak.com I used
   `kyle` as the "Name" and the string from Google as the "Content". TTL Auto.
1. Go back to the search console page and verify
1. Click the link to go to your domain

The domain name can now be bound to a GCS storage bucket.



# Link Domain Name to Storage Bucket
## Update DNS CNAME Record
Update the subdomain CNAME record to point to Google's API URL.
In CloudFlare I made a CNAME entry for `kyle.pericak.com` that looked like this
:

- Name: `kyle`
- Content: `c.storage.googleapis.com`


## Create a Storage Bucket with Matching Name
Go to the [Google Cloud Storage Browser](https://console.cloud.google.com/storage/browser).
Click Create Bucket up at the top.

1. Enter your FQDN in the bucket name. For example, I used `kyle.pericak.com`
1. Location Type: Region
1. Location: northamerica-northeast1
1. Storage Class: standard
1. Access Control: Per-object (not bucket-only)
1. Encryption: Google managed keys
1. Create

The storage bucket now exists and is ready to host the static content.


## Configure Storage Bucket for Access Control & Index File
### Update GCS Bucket Permissions
Update that user to assign the storage roles.

1. From the sidebar go Storage
1. Click the 3 dots to the right of this storage bucket
1. Edit Bucket Permissions
1. New Members: `allUsers`
1. Add the role `Storage Object Viewer`


### Configure index.html as the MainPageSuffix
GCS doesn't know where the page root is.
1. click on the 3 dots to the right of the bucket name
1. click Edit Website Configuration
1. Main page: index.html



### Set the default ACL for the bucket
This can be done from the command-line using `gsutil`.

If this isn't done then the website will show XML with an error stating
`Anonymous caller does not have storage.objects.list access`.

```bash
gsutil defacl ch -u AllUsers:R gs://kyle.pericak.com
```

Alternatively, this can be done from the cloud UI from [console.cloud.google.com/storage/](https://console.cloud.google.com/storage/).

Go to the bucket named after the domain, then Permissions. The permissions can
be modified here.


---


# Push Site Content to GCS

Run the gsutil rsync module to upload files to GCS. Note that `$dst_url` is
pointing at my domain-associated cloud storage bucket.

```bash
# -r    recurse - sync directories
# -c    compare checksums instead of mtime
# -d    Delete extra files under dst_url not found under src_url
src_url="./output"
dst_url="gs://kyle.pericak.com"
gsutil -m rsync -r -c -d $src_url $dst_url
```

---


# Reference Links
- [cloud.google.com - Hosting a Static Website](https://cloud.google.com/storage/docs/hosting-static-website)


---

# Next  Up
Now that you have a fully functional site hosted by Google Cloud Storage,
you can use Cloud-Builder to
[automatically rebuild the site every time you push it to GitHub](/htsw-5-cloud-build-static-site.html).
