description: Vim Spell-Check
slug: vim-spellcheck
category: operations
tags: ops, vim
date: 2019-10-25
modified: 2019-10-25
status: published


When using VIM to write markdown files, spelling becomes a concern. As of Vim
7, spell-checking is a built-in feature.


The spell checker will highly incorrectly spelled words in red. It will
highlight words that are in another dictionary (such as `en_us`) in blue.

# Commands

## Enable/Disable

Enable spellcheck
- `set` for all buffers, `setlocal` for the current one
- `en_ca` will use Canadian spelling.

```text
:set spell spelllang=en_ca
:setlocal spell spelllang=en_ca
```

Or if you'te not picky, the easier to remember:
```
:set spell
```

Disable spellcheck:

```text
:set nospell
```


## Using Spell-Check

Move to the next misspelled word

```
]s
```
previous misspelled word

```
[s
```

Highlight a misspelled word. Show possible replacements.
Press return with no input to go back.

```
z=
```

Accept the spelling of a word:
```text
zg
```

Mark a word's spelling as wrong
```text
zw
```
