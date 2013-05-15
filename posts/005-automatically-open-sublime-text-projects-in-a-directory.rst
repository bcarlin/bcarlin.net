.. tags: Sublime Text 2
.. slug: automatically-open-sublime-text-projects-in-a-directory
.. link:
.. description:
.. title: Automatically open Sublime Text projects in a directory
.. date: 2013/05/15

I usually start Sublime Text 2 from the command line to work,  depending
on the case, on the content of a directory or on a project (materialized
with a ``*.sublime-project`` file).

It ends up with one of the following commands :

- ``subl .``
- ``subl my-project.sublime-project``

Here is the snippet I added to my .bashrc file to have the ``subl``
command automatically "guess" what I want. It does the following:

- If a path is given (subl "my/file.txt"), it opens the file.
- If nothing is given and a .sublime-project file exists in the current
  directory, it opens it
- If nothing is given and no .sublime-project file has been found, it
  opens the folder.

.. gist:: 5318397
