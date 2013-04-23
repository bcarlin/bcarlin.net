.. title: Setup Nginx for Mediawiki
.. description:
.. date: 2010/09/15
.. tags: Nginx, Mediawiki
.. link:
.. slug: setup-nginx-for-mediawiki

Two weeks ago, I migrated a server from Apache/mod_php to nginx/php-fpm. Only
today did i succeed to remove all side effects. The latest one:

Static files must not go through php-fpm, but a simple test on extensions
is ineffective, as url like ``http://server/File:name_of_the_file.png``
must be processed by PHP.

Here is my final setup, that corrects all the errors I encountered:

.. code:: nginx
   :number-lines:

    server {
        listen 80;
        server_name server_name;
        index index.php;
        root /path/to/www/;

        # Serve static files with a far future expiration
        # date for browser caches
        location ^~ /images/ {
            expires 1y;
        }
        location ^~ /skins/ {
            expires 1y;
        }

        # Pass the request to php-cgi
        location / {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_param  SCRIPT_FILENAME $document_root/index.php;
            fastcgi_index  index.php;
            include fastcgi_params;
        }
    }
