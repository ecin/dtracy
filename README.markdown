Dtracy
======

Dtracy 

gem dependencies
------------

* rack
* sinatra
* ruby-dtrace
* haml
* thin

requirements
------------

You'll need an operating system that has support for Dtrace. For the moment, that means Solaris, OS X, or FreeBSD.


Running it
----------

`thin -R bin/server.ru --threaded start`

Visit `/` and you'll see a pulsating circle. Give it some time to calm down, but once it has, visit `/push` to give it a jerk.