title: Python Cheat Sheet / Reference Page
description: Useful code patters for python code
slug: python-cheat-sheet
category: python
tags: python
date: 2019-09-04
modified: 2019-09-04
status: published


[TOC]


---



# Get an object from list of objects where the object property has value x

## A subset list is expected: list comprehension

See [Section 5.1.3 - List comprehension](https://docs.python.org/3/tutorial/datastructures.html)

```python
# This will return a list of objects whith a value
[obj for obj in haystack_list if obj.value == search]

# Example of list comprehension to get the even numbers in a list
nums = [1, 2, 3, 4, 5, 6, 7, 8]
even_nums = [num for num in nums if num % 2 == 0]
```


## Get one match: next() w/ generator expression

The `next()` method will return the first element found in an iterable.

See [PEP 289 - Generator expressions](https://www.python.org/dev/peps/pep-0289/)

```python
# Raises a StopIteration exception if no match is found
needle = next((obj for obj in haystack_list if obj.value == value))

# To return a value instead of raising an exception, pass a second argument
needle = next((obj for obj in haystack_list if obj.value == search), None)

# Example of what Next is really doing. This returns 1.
next(iter([1,2,3]))
```


---


# Print JSON nicely in ASCII (no unicode 'u' prefix)

```python
data = ... # the json string
jdata = json.dumps(json.loads(data),  indent=4, sort_keys=True)
print(jdata)
```


