.. tags: Python, Buzhug, Database, Locks
.. slug: locking-buzhug
.. link:
.. description:
.. title: Locking Buzhug
.. date: 2012/02/07

I have recently decided to work with `Buzhug`_ on a project. As far as I can tell,
it has proven efficient, fast, easy to use and to maintain. However, I ran into
a few gotchas.

.. _Buzhug: http://buzhug.sourceforge.net

Simple solutions are often the best
===================================

I came to use Buzhug for the following requirements:

- I needed a single table
- I did not want to add additional dependencies to the project
- The size of the table will average 5K entries (without having more than
  10k entries in peaks)

And an additional (personal) one:

- I did not want to bother with SQL. Really not. no way!

That left me one option: pure-python embedded database.

After having considered a few libraries, I have been seduced by the way Buzhug
interface is close to manipulating python objects. And the benchmarks seemed
to show that it is performant enough for this project.

After a quick prototyping (1 day), the choice was done.

Then came a few weeks of development and the first stress tests...


And the real world came back fast
=================================


A few times a day, the application backed by this database is intensely used:

- It can be run up to 50 times simultaneously in separate python process
- Each run makes a read and a write/delete operation

This causes a race condition on the files used to store data, and concurent
writes corrupts database.

Using ``buzhug.TS_Base`` instead of ``buzhug.Base`` did not solve anything,
as the problem is not thread, but processes. What I need is a system-wide
cross-process lock.

Here is the answer
==================

First step was to find how to implement a cross-process, system-wide lock.
As it only has to work on Linux, the
`Lock class given by Chris from Vmfarms
<http://blog.vmfarms.com/2011/03/cross-process-locking-and.html>`__ fits
perfectly. Here is a version slightly modified to make it a context manager :


.. code:: python
   :number-lines:

    import fcntl

    class PsLock:
        """
        Taken from:
        http://blog.vmfarms.com/2011/03/cross-process-locking-and.html
        """
        def __init__(self, filename):
            self.filename = filename
            self.handle = open(filename, 'w')

        # Bitwise OR fcntl.LOCK_NB if you need a non-blocking lock
        def acquire(self):
            fcntl.flock(self.handle, fcntl.LOCK_EX)

        def release(self):
            fcntl.flock(self.handle, fcntl.LOCK_UN)

        def __del__(self):
            self.handle.close()

        def __exit__(self, exc_type, exc_val, exc_tb):
            if exc_type is None:
                pass
            self.release()

        def __enter__(self):
            self.acquire()


The second step is to define a new class that inheritates from ``buzhug.Base``
that uses ``PsLock`` (inspired by ``TS_Base``):


.. code:: python
   :number-lines:

    import buzhug

    _lock = PsLock("/tmp/buzhug.lck")

    class PS_Base(buzhug.Base):

        def create(self,*args,**kw):
            with _lock:
                res = buzhug.Base.create(self,*args,**kw)
            return res

        def open(self,*args,**kw):
            with _lock:
                res = buzhug.Base.open(self,*args,**kw)
            return res

        def close(self,*args,**kw):
            with _lock:
                res = buzhug.Base.close(self,*args,**kw)
            return res

        def destroy(self,*args,**kw):
            with _lock:
                res = buzhug.Base.destroy(self,*args,**kw)
            return res

        def set_default(self,*args,**kw):
            with _lock:
                res = buzhug.Base.set_default(self,*args,**kw)
            return res

        def insert(self,*args,**kw):
            with _lock:
                res = buzhug.Base.insert(self,*args,**kw)
            return res

        def update(self,*args,**kw):
            with _lock:
                res = buzhug.Base.update(self,*args,**kw)
            return res

        def delete(self,*args,**kw):
            with _lock:
                res = buzhug.Base.delete(self,*args,**kw)
            return res

        def cleanup(self,*args,**kw):
            with _lock:
                res = buzhug.Base.cleanup(self,*args,**kw)
            return res

        def commit(self,*args,**kw):
            with _lock:
                res = buzhug.Base.commit(self,*args,**kw)
            return res

        def add_field(self,*args,**kw):
            with _lock:
                res = buzhug.Base.add_field(self,*args,**kw)
            return res

        def drop_field(self,*args,**kw):
            with _lock:
                res = buzhug.Base.drop_field(self,*args,**kw)
            return res

Now I just use


.. code:: python
   :number-lines:

    database = PS_Base( ... )


And all the errors have vanished.
