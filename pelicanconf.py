#!/usr/bin/env python
"""Pelican Config File"""
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals


AUTHOR = 'Kyle Pericak'
SITENAME = 'Kyle Pericak'
THEME = "/theme"
SITEURL = ''
PATH = 'content'
OUTPUT_PATH = 'output'
TIMEZONE = 'America/Toronto'
DEFAULT_LANG = 'en'
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None
# RELATIVE_URLS = True
LINKS = (
    ('Check out Breqwatr!', 'https://breqwatr.com'),
    ('Support OpenMedia', 'https://openmedia.org/en/ca'))
DEFAULT_PAGINATION = 10
PANDOC_ARGS = (['--toc', '--template=pandoc-template-toc'])
MARKDOWN = {
    'extension_configs': {
        'markdown.extensions.toc': {'title': 'Table of contents:'},
        'markdown.extensions.codehilite': {'css_class': 'highlight'},
        'markdown.extensions.extra': {},
        'markdown.extensions.meta': {}},
    'output_format': 'html5'}

# plugin settings
PLUGIN_PATHS = ['/plugins']
PLUGINS = ['series']

# voidy config
SIDEBAR = "sidebar.html"
STYLESHEET_FILES = (
    "pygment.css",
    "voidybootstrap.css",
    "pericak-override.css")
CUSTOM_SIDEBAR_MIDDLES = ("sb_links.html", "sb_taglist.html", )
SITESUBTITLE = "\"It works in my environment.\""
SITETAG = "Tech Blog"

# extra files (pictures, robots, etc)
STATIC_PATHS = ['images', 'extra', 'pdfs']
EXTRA_PATH_METADATA = {
    'extra/favicon.ico': {'path': 'favicon.ico'},
    'extra/apple-touch-icon.png': {'path': 'apple-touch-icon.png'},
    'extra/favicon-16x16.png': {'path': 'favicon-16x16.png'},
    'extra/favicon-32x32.png': {'path': 'favicon-32x32.png'}}
