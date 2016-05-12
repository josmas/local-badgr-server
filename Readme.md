# Badgr.io local server setup
This is a development setup, not intended for production. It is intended to be
used as a local Badgr server in an scenario in which Badgr is used as a
dependency. One such case is [PaperBadger](https://github.com/mozillascience/PaperBadger),
but it can be used for any other project. This is __not__ a development environment for the
Badgr server itself, but a way to easily run the server within a local setup to be used as
a dependency. As such, the Badgr sources are hosted within the container
(not shared with the host), the latest code on github (at install time) will be pulled in,
and the installation relies on a local sqlite3 db.

The instructions to install Badgr are not very clear, so this container may be pulling in
more (hopefully no less) dependencies that it actually needs.

# How to build the image
Build the image with:
`docker build -t <your_name>/local-badgr-server .` do not forget the dot at the
end, and change _<your_name>_ to your _docker hub_ username or some other of your choosing.

The image creates a 'badgr' user with no password and in the sudoers group.
The sources are at `/home/badgr/badgr-server`.

# How to use the image
Use the script _runBashBadgr.sh_ to start a bash session with the badgr user. Make sure you
change _<your_name>_ to the name you used when building the image. The script simply runs a
bash session in the container so you can take it from there. You can run it manually with:

`docker run -ti --rm --name local-badgr-server -p 8000:8000 <your_name>/local-badgr-server /bin/bash`

The first time you run the container you will probably want to create a
superuser with:

`./manage.py createsuperuser` Follow the prompts to provide the information
needed. The migrations have already been run, but any changes you make once you
start using the image, will need to be _committed_ to the container.

Start up the server with:

`./manage.py runserver`

As specified in the Dockerfile, virtualenv is not used, but everything is in place if you would
like to do so.

Note that any changes you make to either the container, the code, or the DB, will have to be
persisted through [docker commit](https://docs.docker.com/engine/reference/commandline/commit/)
if they need to be available when you restart the container.

## Notes for Mac and Windows users

If you are not on Docker Beta, and your Docker does not run natively, this server will be
available in an ip such as `http://192.168.99.100:8000/`. Make sure you make the appropriate
changes when needed. For instance, you may need to start up the server as follows:
`./manage.py runserver 0.0.0.0:8000`

You will also have to change the HTTP_ORIGIN variable in the local settings
file `apps/mainsite/settings_local.py` to point to your ip:port. More 
[info](https://github.com/concentricsky/badgr-server/issues/33) about why that change is needed. 

Jos - May 2o16
