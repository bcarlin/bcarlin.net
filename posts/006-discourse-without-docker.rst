.. title: Discourse without Docker
.. slug: discourse-without-docker
.. date: 2016-06-27 10:46:23 UTC+02:00
.. tags: discourse,docker
.. link:
.. description:
.. type: text

.. warning::

   The only official method is `with docker`_. You might not be able to
   get support from Discourse by following this method.


The team behind Discourse_ has chosen to only release Docker images of
their software. The rational behind it is: it is easier to only support
a single setup. I will not discuss that. It is their choice.

However, I don't like to use docker to deploy apps in prodution. I even
hate it. If you are like me, here are the steps I used to install it
and to set it up.

I use Debian servers in production, so the steps below are all debian
oriented.

.. note::

   This is not intended as a comprehensive guide. A lot of commands and
   configuration files might need to be adapted to your environment.

   It does not even tries to talk about important topics in production
   such as security. This is left as an exercise to the reader.

.. contents::

Installation
============

After all, Discourse is a rails application. It can be installed likee
any other rails application:

#. First things first: Discourse uses Redis and PostgreSQL (or at least,
I prefer to use Postgres. I also use Nginx as a proxy to the
application. Install the external dependencies:

   .. code:: bash

      # Add the reposirory for Redis
      echo deb http://packages.dotdeb.org jessie all > /etc/apt/sources.list.d/dotdeb.list
      wget https://www.dotdeb.org/dotdeb.gpg -O - | apt-key add -

      # Add the repositori for PostgreSQL:
      echo deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main > /etc/apt/sources.list.d/postgresql.list
      wget -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

      apt-get update
      apt-get install postgresql-9.5 redis-server nginx

   Then, create a database for the application. Enter postgres command
   line interface:

   .. code::

      su - postgres -c psql

   and enter the following commands:

   .. code:: SQL

      CREATE DATABASE discourse;
      CREATE USER discourse;
      ALTER USER discourse WITH ENCRYPTED PASSWORD 'password';
      ALTER DATABASE discourse OWNER TO discourse;
      \connect discourse
      CREATE EXTENSION hstore;
      CREATE EXTENSION pg_trgm;

#. Then, you can checkout the Discourse code:

   .. code:: bash

      git clone https://github.com/discourse/discourse.git /path/to/discourse

      # Optionally, checkout a specific tag
      cd /path/to/discourse
      git checkout v1.5.3

#. Then, go in the application top directory, and set it up as any rails
   application:

   .. code:: bash

      # Optionally setup rvm with ruby 1.9.3 minimum (I use 2.3.0)
      rvm install 2.3.0
      rvm use 2.3.0

      # install dependencies
      cd /path/to/discourse
      RAILS_ENV bundle install

#. It's time to configure the application.

   Here, Discourse has a little particularity: The production
   configuration is located in the file ``./config/discourse.conf``.

   Create this file :

   .. code:: bash

      cp config/discourse_defaults.conf config/discourse.conf

   And edit it with your configuration. The main areas of interest are
   configuration for the database and for the email server:

   .. code::

      # host address for db server
      # This is set to blank so it tries to use sockets first
      db_host = localhost

      # port running db server, no need to set it
      db_port = 5432

      # database name running discourse
      db_name = discourse

      # username accessing database
      db_username = discourse

      # password used to access the db
      db_password = password

   and for the SMTP server (in this example, we use Gmail):

   .. code::

      # address of smtp server used to send emails
      smtp_address = smtp.gmail.com

      # port of smtp server used to send emails
      smtp_port = 587

      # domain passed to smtp server
      smtp_domain = gmail.com

      # username for smtp server
      smtp_user_name = your-address@gmail.com

      # password for smtp server
      smtp_password = password

      # smtp authentication mechanism
      smtp_authentication = plain

      # enable TLS encryption for smtp connections
      smtp_enable_start_tls = true

#. Now, we can prepare discourse for production:

   .. code:: bash

      RAILS_ENV=production bundle exec rake db:migrate
      RAILS_ENV=production bundle exec rake assets:precompile

#. It is time to start the application. I usually use Puma to deploy
   Rails app.

   Create the file ``config/puma.rb`` in discourse directory. Following
   content should be enough (for more info, see
   `Puma's documentation`_):

   .. code:: ruby

      #!/usr/bin/env puma

      application_path = '/home/discuss.waarp.org/discourse'
      directory application_path
      environment 'production'
      daemonize false
      pidfile "#{application_path}/tmp/pids/puma.pid"
      state_path "#{application_path}/tmp/pids/puma.state"
      bind "unix://#{application_path}/tmp/sockets/puma.socket"

   From there, the application can be run with the following command :

   .. code:: bash

      bundle exec puma -C config/puma.rb

#. Finally, setup nginx to forward requests to Discourse. Create the file
   ``/etc/nginx/conf.d/discourse.conf`` with the following content :

   .. code::

      upstream discourse {
          server unix:/path/to/discourse/tmp/sockets/puma.socket;
      }

      server {
          listen 80;
          server_name example.com;

          location / {
              try_files $uri @proxy;
          }

          location @proxy {
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_pass http://discourse;
          }
      }

Your very own forum with Discourse is setup!

Service Management
==================

According to your workflow, you can add systemd units to run discourse.
It needs at least two srevice definition :

1. Sidekiq, which is used to process asynchronous background tasks
2. Rails, for Discource itself.

   less /etc/systemd/system/discuss.waarp.org.service
   nano config/sidekiq.yml

With the services setup, services ca be started/stopped/enabled with
``systemctl`` commands.

But before that, if you use RVM, you must create a wrapper for the
environment (local ruby, and optional gemset) used by Discourse:

.. code:: bash

   rvm wrapper 2.3.0 systemd bundle

This creates an executable in ``$rvm_bin_path`` that you can call
in lieu of bundle that will automatically load the right envirnoment.

Sidekiq
-------

First, create a configuration for sidekiq. Create the file
``config/sidekiq.yml`` in your discoure project with the following
content (for more info, see `Sidekiq's documentation`_):

.. code:: yaml

   ---
   :concurrency: 5
   :pidfile: tmp/pids/sidekiq.pid
   staging:
     :concurrency: 10
   production:
     :concurrency: 20
   :queues:
     - default
     - critical
     - low

Then, create the service unit for Sidekiq. Create the file
``/etc/systemd/system/discourse-sidekiq.service`` with the
following content:

.. code:: ini

   [Unit]
   Description=discourse sidekiq service
   After=multi-user.target

   [Service]
   WorkingDirectory=/path/to/discourse
   Environment=RAILS_ENV=production
   ExecStart=/path/to/rvm/.rvm/bin/systemd_bundle exec sidekiq -C config/sidekiq.yml
   Restart=always
   RestartSec=10

   [Install]
   WantedBy=multi-user.target


Discourse
---------

For Discourse, just create the service unit for Puma. Create the file
``/etc/systemd/system/discourse.service`` with the
following content:

.. code:: ini

   [Unit]
   Description=discourse service
   After=discourse-sidekiq.service
   Requires=discourse-sidekiq.service

   [Service]
   WorkingDirectory=/path/to/discourse
   Environment=RAILS_ENV=production
   ExecStart=/path/to/rvm/.rvm/bin/systemd_bundle exec puma -C config/puma.rb
   Restart=always
   RestartSec=10

   [Install]
   WantedBy=multi-user.target

Upgrades
========

Upgrades are even easier:

1. First read the release notes.
2. Make backups of the code and the database.
3. Checkout the newest version:

   .. code:: bash

      cd /path/to/discourse
      git checkout vX.X.X

4. Install the new dependencies, run the migrations and rebuild the
   assets:

   .. code:: bash

      RAILS_ENV=production bundle install
      RAILS_ENV=production bundle exec rake db:migrate
      RAILS_ENV=production bundle exec rake assets:precompile

5. Restart Discourse:

   .. code:: bash

      systemctl restart discourse

What can go wrong? If if I do not give any solution here, it is always
recoverable (hence the backups!).

- The database migration failed (restore the database with your backup,
  fix the problem and try again!)
- The plugins are not compatible with the latest version (rollback to
  the previous working solution and wit for them to be compatible)


Plugins
=======

Discourse plugins can be handles the same way.

Installation
------------

1. Install the plugin with the url of its repository:

   .. code:: bash

      cd /path/to discourse
      RAILS_ENV=production bundle exec rake plugin:install[URL]

2. Install the new dependencies, run the migrations and rebuild the
   assets:

   .. code:: bash

      RAILS_ENV=production bundle install
      RAILS_ENV=production bundle exec rake db:migrate
      RAILS_ENV=production bundle exec rake assets:precompile


3. Restart Discourse:

   .. code:: bash

      systemctl restart discourse


Upgrade
-------

To upgrade a specific plugin, use the following command:

.. code:: bash

   RAILS_ENV=production bundle exec rake plugin:update[ID]

You can also upgrade all plugins at once with the command:

.. code:: bash

   RAILS_ENV=production bundle exec rake plugin:update_all

Then, install the new dependencies, run the migrations and rebuild the
assets:

.. code:: bash

   RAILS_ENV=production bundle install
   RAILS_ENV=production bundle exec rake db:migrate
   RAILS_ENV=production bundle exec rake assets:precompile


and restart Discourse:

.. code:: bash

   systemctl restart discourse


.. _with docker: http://blog.discourse.org/2014/04/install-discourse-in-under-30-minutes/
.. _Discourse: http://www.discourse.org/
.. _Sidekiq's documentation: https://github.com/mperham/sidekiq/wiki/Advanced-Options
.. _Puma's documentation: https://github.com/puma/puma