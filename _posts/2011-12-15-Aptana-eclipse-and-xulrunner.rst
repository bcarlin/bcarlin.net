---
layout: blogpost
title: Aptana Studio/Eclipse and Xulrunner
date: 2011/12/16 17:00:00 
categories: developer-life
tags: aptana-studio eclipse xulrunner arch-linux
---

Since a few months, I encountered an annoying error in Aptana Studio and 
Eclipse 3.7 (the autonomous packages, not the packages from the repositories)
whenever I tried to do a git or hg action.

I could live without until now, but today, it was really bothering me.

The error is:

{% highlight text %}
Unhandled event loop exception
No more handles [Unknown Mozilla path (MOZILLA_FIVE_HOME not set)]
{% endhighlight %}

The log file showed the following backtrace:

{% highlight text %}
!ENTRY org.eclipse.ui 4 0 2011-12-16 17:17:30.825
!MESSAGE Unhandled event loop exception
!STACK 0
org.eclipse.swt.SWTError: No more handles [Unknown Mozilla path (MOZILLA_FIVE_HOME not set)]
	at org.eclipse.swt.SWT.error(SWT.java:4109)
	at org.eclipse.swt.browser.Mozilla.initMozilla(Mozilla.java:1739)
	at org.eclipse.swt.browser.Mozilla.create(Mozilla.java:656)
	at org.eclipse.swt.browser.Browser.<init>(Browser.java:119)
	at com.aptana.git.ui.internal.actions.CommitDialog.createDiffArea(CommitDialog.java:237)
	at com.aptana.git.ui.internal.actions.CommitDialog.createDialogArea(CommitDialog.java:158)

    [...]

	at org.eclipse.equinox.launcher.Main.invokeFramework(Main.java:620)
	at org.eclipse.equinox.launcher.Main.basicRun(Main.java:575)
	at org.eclipse.equinox.launcher.Main.run(Main.java:1408)
	at org.eclipse.equinox.launcher.Main.main(Main.java:1384)
{% endhighlight %}

To make it short, after having read `a <https://bugs.archlinux.org/task/5149>`__
`lot <https://bugs.archlinux.org/task/27130>`__ 
`of <https://github.com/eclipse-color-theme/eclipse-color-theme/issues/50>`__ 
`posts <https://bbs.archlinux.org/viewtopic.php?id=129982>`__ 
`about <http://forums.gentoo.org/viewtopic-t-827838-view-previous.html?sid=546c5717e2167c45d9b02f9f20ab36f4>`__ 
`this <http://stackoverflow.com/questions/1017945/problem-with-aptana-studio-xulrunner-8-1>`__
`problem <http://www.eclipse.org/swt/faq.php#gtk64>`__, it seemed it was enough
to give the path to Xulrunner to Aptana.

on my Arch Linux, it was 

{% highlight bash %}
export MOZILLA_FIVE_HOME=/usr/lib/xulrunner-8.0
{% endhighlight %}

Trying to start Aptana Studio, I had a new error. It simply stated

{% highlight text %}
XPCOM error -2147467261
{% endhighlight %}

The solution is that Aptana Studio cannot work with the version of Xulrunner 
in Arch LinuX repositories because it is too recent.

To solve this problem, I had to install xulrunner 1.9.2 from AUR:

yaourt -S xulrunner192

The PKGBUILD was broken this morning and ended in a 404 Error when fetching
sources. If you have the same problem, `here is an updated PKGBUILD
<https://gist.github.com/1486851>`__

Finally, I put 

{% highlight bash %}
-Dorg.eclipse.swt.browser.XULRunnerPath=/usr/lib/xulrunner-1.9.2
{% endhighlight %}

at the end of the ``AptanaStudio3.ini`` file in the Aptana Studio folder.

 