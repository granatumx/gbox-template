# You probably want to start with a working image
FROM python:3.8.2
MAINTAINER "Your Name" your.name@gmail.com

# Initial environment variables for install =========================================
ENV TERM=xterm-256color
ENV PATH="$PATH:./"
# Disable front end for automated install with no errors
ENV DEBIAN_FRONTEND noninteractive
ENV TZ America/New_York

RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y build-essential git
RUN apt-get install -y curl
RUN apt-get install -y bash bash-completion

# Set up editor to your liking here. =========================================

# Install vim if that is the type of editor you like
RUN apt-get install -y vim
# Typescript highlighting has not been merged
WORKDIR /tmp
# RUN git clone https://github.com/leafgarland/typescript-vim.git ~/.vim/pack/typescript/start/typescript-vim
RUN echo "syntax on" > ~/.vimrc

# Install micro if that is how you like to develop, uncomment the next two lines
# RUN curl https://getmic.ro | bash
# RUN mv micro /usr/local/bin

# Install prerequisites here. =========================================

# For setting up python, you can use
# RUN pip install --upgrade pip

# Docker can be useful for editing inside of docker and building
RUN apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN apt-get update
RUN apt-get install -y docker-ce-cli

# Install prerequisites here. =========================================

# Easiest to create an app directory in /usr/src
WORKDIR /usr/src/app

COPY . .

# Run necessary build scripts here

# Set version correctly so user can install gbox
# Requires bash and sed to set version in yamls
# Can modify if base OS does not support bash/sed
RUN apt-get update
RUN apt-get install -y sed bash
ARG VER=1.0.0
ARG GBOX=gbox:1.0.0
ENV VER=$VER
ENV GBOX=$GBOX
WORKDIR /usr/src/app
# In order to keep versions up-to-date, YAMLS have a {VER} and {GBOX}
# tag which can be used and translated to the present build.
# You do not need to go through files by hand to change the version.
RUN ./GBOXtranslateVERinYAMLS.sh
# You want to create a TGZ in / with the package.yaml recipes/* and yamls/*
# Then the installer can easily pull this file for dropping correct entries
# into the gx-database
RUN ./GBOXgenTGZ.sh

# Set up the default shell to run which sources bashrc
COPY .bashrc /root/.bashrc
# You can then place whatever aliases you like in /root/.bash_aliases
SHELL [ "/bin/bash", "-i", "-l", "-c" ]
CMD python ./greet.py
