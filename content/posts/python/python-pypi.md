title: Upload a Python Package to PyPi
description: Uploading a python package to PyPi so it can be pulled with pip
slug: python-pypi
category: python
tags: python
date: 2019-09-06
modified: 2019-09-06
status: draft


1. Write the project code
1. Write a setup.py file to build and describe the project
1. Write a setup.cfg file pointing to the readme
1. Create a release on github and put it in the `download_url` of setup.py
1. create a source distribution


# Write the project code

I'm not going to cover how to build a python project in this post, but here's
the very small and simple project I used when learning this procedure:
[GitHub: kylep/jsc2f](https://github.com/kylep/jsc2f).

# Write a setup.py file

Here's mine, but with comments I don't actually have in the code.
The `download_url` value comes from the GitHub release, which you might not
have made yet. Just push, make the release, then push again.

```python
from setuptools import setup

# Without this you'll get no description on the pypi site
with open("README.md", "r") as fh:
    long_description = fh.read()

setup(
    name='jsc2f',
    packages=['jsc2f'], # Alternatively you can use find_packages()
    version='0.1', # match the github release you make later
    license='MIT', # match the LICENSE file in the project
    description='Saves a JSON fields SQLs cell to a file, or UPDATE it back',
    author='Kyle Pericak',
    author_email='kyle@pericak.com',
    url='kyle.pericak.com/jsc2f', # either your own page or github
    download_url='https://github.com/kylep/jsc2f/archive/v0.1.tar.gz',
    keywords=['SQL', 'JSON', 'file'],
    install_requires=[
        'click',
        'mysql-connector'
    ],
    entry_points='''
        [console_scripts]
        jsc2f=jsc2f.cli:cli
    ''',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Information Technology',
        'Topic :: Database',
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Natural Language :: English'

```

# Writing setup.py
Picking a topic:
I used [this classifier list](https://pypi.org/pypi?%3Aaction=list_classifiers)


# Creating a source distribution

For this you use the python [sdist](https://docs.python.org/2/distutils/sourcedist.html)
tool and [twine](https://pypi.org/project/twine/).

from the git project root:

```bash
pip install twine

# This will create dist/
python setup.py sdist

# Twine uploads the dist/ files to Pypi
twine upload --skip-existing dist/*
# Enter your username and password for PyPI
```



