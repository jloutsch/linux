layout: post
title: Using nonlocal in Python Closures
categories: [python]
tags: [python, closures, decorators, nonlocal]
---
# Using `nonlocal` in Python Closures

*-Only applicable for Python3*

I've always struggled to understand what the Python `nonlocal` keyword was useful for. It was only after dabbling with Javascript, and fully wrapping my head around closures until I finally realized that Python doesn't fully support closures as you would normally expect.

If you want to save any kind of state with your closure, you will only be able to read the variable, **not** modify *or* even use it in a conditional.

For Example, assume you have following decorator (which is just a closure) that will only run the specified function once the counter reaches 0:

```python
def countDown(num):
    def decorator(f):
        def inner(*args, **kwargs)
            if num < 1:
                f(*args, **kwargs)
            num -= 1            
        return inner
    return decorator

@countDown(3)
def hello():
    print('Hello World')

hello()
```

If you try to run this code then you will receive the following exception:

```python
Traceback (most recent call last):
  File "c:\Users\lukep\projects\Linux\docs\test.py", line 14, in <module>
    hello()
  File "c:\Users\lukep\projects\Linux\docs\test.py", line 4, in inner
    if num < 1:
UnboundLocalError: local variable 'num' referenced before assignment
```


If you're familiar with closures then this should probably come as a big shock because you've been told the language supports closures, and that the `num` variable would have its state saved.

To fix this, you have to stick a `nonlocal` declaration in the *same* block that you use the variable in:

```python
def countDown(num):
    def decorator(f):
        def inner(*args, **kwar:w
            gs)
            nonlocal num
            if num < 1:
                f(*args, **kwargs)
            num -= 1            
        return inner
    return decorator

@countDown(3)
def hello():
    print('Hello World')

hello()
```

Now the closure will behave as you intuitively expected it to