---
layout: blogpost
title: Build the latest PgPool-II on Debian Etch
date: 2010/12/14 00:00:00 
categories: server-stuff
tags: debian pgpool-II
---

After having build PgPool-II on Red Hat Enterprise Linux 5.5 without any 
problem, I tried to build it on a fresh Debian Etch. The catch is that I did 
not want to install PostgreSQL 9.0, but just extract it from the binary 
packages provided by Entreprisedb (with option ``--extract-only 1``).

Whatever options I passed to ``./configure``, it resulted in the same error:

{% highlight text %}
checking for PQexecPrepared in -lpq... no
configure: error: libpq is not installed or libpq is old
{% endhighlight %}

Here is the answer: the binary package contains the libpq with the name 
``libcrypto.so.0.9.8`` (the RHEL name) when pgpool is looking ``libcrypto.so.6`` 
on Debian. The same applies to ``libssl``. So a simple

{% highlight bash %}
ln -s libcrypto.so.0.9.8 libcrypto.so.0.9.8
ln -s libssl.so.0.9.8 libssl.so.6
{% endhighlight %}

before your ``./configure`` will solve it!