title: Remove/Delete a File from Git History
summary: Deleting a file that has been pushed to git
slug: remove-file-from-git-history
tags: dev
category: git
date: 2019-09-06
status: published


While writing a [tool to download JSON fields from SQL tables](/jsc2f.html),
I accidentally uploaded the .sql file I had been using for testing. It didn't
have anything really secret in it, but I still didn't want it in my history.
Here's how I deleted it.

It's important to note, as GitHub highlights [in their documentation](https://help.github.com/en/articles/removing-sensitive-data-from-a-repository),
if you've uploaded a secret password or something, you still need to change it.


---


# Delete a File From Git History

The file was called `sqldata.json`, and it was in my project root.
From the project root, I ran:

```bash
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch sqldata.json" \
  --prune-empty --tag-name-filter cat -- --all

git push origin --force --all
```

## If you don't push with --force

When I tried to push, though, I got an error. I'd forgotten to use `--force`.

```bash
To https://github.com/kylep/jsc2f.git
 ! [rejected]        master -> master (non-fast-forward)
 error: failed to push some refs to 'https://github.com/kylep/jsc2f.git'
 hint: Updates were rejected because the tip of your current branch is behind
 hint: its remote counterpart. Integrate the remote changes (e.g.
 hint: 'git pull ...') before pushing again.
 hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

Then, when I tried to pull, I got

```bash
From https://github.com/kylep/jsc2f
 + ca7d7cc...710d37b master     -> origin/master  (forced update)
 fatal: refusing to merge unrelated histories
```

If you're getting errors like that, maybe you need to run push with `--force`.

```bash
git push origin --force --all
```

