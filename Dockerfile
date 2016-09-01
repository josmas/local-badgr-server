FROM ubuntu:14.04

# Build with
#    docker build -t <your_name>/local-badgr-server .

RUN apt-get update

# Install main dependencies
Run apt-get install -y libffi-dev libxslt-dev libsasl2-dev libldap2-dev
Run apt-get install -y libmariadbclient-dev zlib1g-dev python-dev libssl-dev python-virtualenv

# Install other useful tools
RUN apt-get install -y git vim sudo curl unzip
RUN apt-get install -y sqlite3

# Clean up
RUN apt-get clean
RUN apt-get purge

# Set up user permissions
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/badgr && \
    echo "badgr:x:${uid}:${gid}:Badgr,,,:/home/badgr:/bin/bash" >> /etc/passwd && \
    echo "badgr:x:${uid}:" >> /etc/group && \
    echo "badgr ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/badgr && \
    chmod 0440 /etc/sudoers.d/badgr && \
    chown ${uid}:${gid} -R /home/badgr

EXPOSE 8000

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
USER badgr
ENV HOME /home/badgr
ENV NVM_DIR=$HOME/.nvm
WORKDIR $HOME

RUN touch /home/badgr/.bashrc \
  && curl https://raw.githubusercontent.com/creationix/nvm/v0.31.1/install.sh | /bin/bash \
  && echo $HOME && echo $NVM_DIR \
  && ls -lisa .nvm \
  && source $HOME/.bashrc \
  && source $NVM_DIR/nvm.sh \
  && nvm install v5 \
  && nvm alias default 5 \
  && nvm use default

# Install Ruby2
RUN sudo apt-get install ruby2.0 -y
RUN sudo ln -sf /usr/bin/ruby2.0 /usr/bin/ruby
RUN sudo ln -sf /usr/bin/gem2.0 /usr/bin/gem
RUN sudo gem install sass --no-rdoc --no-ri

# Installing Badgr
RUN source $NVM_DIR/nvm.sh && nvm use default && npm install -g grunt-cli
# Not running virtualenv because this server will only run Badgr requirements.
# If it is needed, add to the next RUN (before pip) ' && virtualenv env && source env/bin/activate \'
RUN git clone https://github.com/concentricsky/badgr-server.git \
    && cd badgr-server \
    && sudo pip install -r requirements-dev.txt \
    && cp apps/mainsite/settings_local.py.example apps/mainsite/settings_local.py \
    && ./manage.py migrate \
    && source $NVM_DIR/nvm.sh && nvm use default &&npm install \
    && grunt dist

# Copy DB from assets/database.
COPY assets/database/local.sqlite3 /home/badgr/badgr-server/
RUN sudo chown badgr:badgr /home/badgr/badgr-server/local.sqlite3

# Copy images for issuer and badges, after creating the appropriate folders
RUN mkdir /home/badgr/badgr-server/mediafiles
RUN mkdir /home/badgr/badgr-server/mediafiles/uploads
RUN mkdir /home/badgr/badgr-server/mediafiles/uploads/badges
COPY assets/images/issuer_badgeclass_* /home/badgr/badgr-server/mediafiles/uploads/badges/

RUN mkdir /home/badgr/badgr-server/mediafiles/uploads/issuers
COPY assets/images/issuer_logo* /home/badgr/badgr-server/mediafiles/uploads/issuers/
