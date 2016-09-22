# Badgr-server local setup
This is a development setup, not intended for production. It is intended to be
used as a local [Badgr](https://github.com/concentricsky/badgr-server) server
in an scenario in which Badgr is used as a dependency. One such case is
[PaperBadger](https://github.com/mozillascience/PaperBadger),
but it can be used for any other projects. This is __not__ a development environment for the
Badgr server itself, but a way to easily run the server within a local setup to be used as
a dependency. As such, the Badgr sources are hosted within the container
(not shared with the host), the latest code on github (at install time) will be pulled in,
and the installation relies on a local sqlite3 db.

The instructions to install Badgr are not very clear, so this container may be pulling in
more (hopefully no less) dependencies that it actually needs.

# How to build the image
Build the image with:

`docker build -t <your_name>/local-badgr-server .`

Do not forget the _dot_ at the end of the build command, and change your_name to your
_docker hub_ username or some other name of your choosing.

The image is based on Ubuntu 14.04, and it creates a 'badgr' user with no password and in the
sudoers group. The sources are at `/home/badgr/badgr-server`.

# How to use the image
You can use the script _runBashBadgr.sh_ to start a bash session with the _badgr_ user. Make sure you
modify the script to change _<your_name>_ to the name you used when building the image. The script
simply runs a bash session in the container so you can take it from there.
You can run it manually with:

`docker run -ti --rm --name local-badgr-server -p 8000:8000 <your_name>/local-badgr-server /bin/bash`

The database copied into the container contains an _Issuer_, a number of
_badges_, and a number of _badge instances_.
It also contains a superuser: the _username_ and _password_ are ___admin___, and the email address is _b@d.gr_.

Start up the server with:

`./manage.py runserver 0.0.0.0:8000`

As specified in the Dockerfile, _virtualenv_ is not used, but everything is in place if you would
like to do so.

Note that any changes you make to either the container, the code, or the DB, will have to be
persisted through [docker commit](https://docs.docker.com/engine/reference/commandline/commit/)
if they need to be available when you restart the container.

## Notes for Mac and Windows users

If you are not on Docker Beta, and your Docker does not run natively, this server will be
available in an ip such as `http://192.168.99.100:8000/`. Make sure you make the appropriate
changes when needed.

You will also have to change the HTTP_ORIGIN variable in the local settings
file `apps/mainsite/settings_local.py` to point to your ip:port. More
[info](https://github.com/concentricsky/badgr-server/issues/33) about why that change is needed.

## Notes about the Badgr server
The Badgr server verifies all accounts (including the superuser) through email. When creating an
account (or logging in for the first time as a superuser), the server will print the verification
URL in the terminal as a log statement. This URL can be copied and pasted in the browser to verify
the account. For more information about the Badgr-server, please consult their
[docs](https://github.com/concentricsky/badgr-server).

Jos - May 2o16
