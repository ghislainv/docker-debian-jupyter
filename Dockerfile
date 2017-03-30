#!/usr/bin/env bash
# docker-debian-jupyter
# Debian dockerfile with jupyter notebook

# Base image
FROM debian:testing
MAINTAINER Ghislain Vieilledent <ghislain.vieilledent@cirad.fr>

# Terminal
ENV TERM=xterm

# Configure default locales
RUN dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN dpkg-reconfigure locales

# Proxy
#ENV PROXY="http://10.168.209.73:8012"
#RUN export http_proxy=$PROXY
#RUN export https_proxy=$PROXY
#RUN export ftp_proxy=$PROXY
#RUN echo "Acquire::http::proxy \""$PROXY"\";" >> /etc/apt/apt.conf
#RUN echo "Acquire::https::proxy \""$PROXY"\";" >> /etc/apt/apt.conf
#RUN echo "Acquire::ftp::proxy \""$PROXY"\";" >> /etc/apt/apt.conf

# Install debian packages with apt-get
ADD apt-packages.txt /tmp/apt-packages.txt
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y \
    && xargs -a /tmp/apt-packages.txt apt-get install -y

# Reconfigure locales
RUN apt-get install -y locales
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Clean-up
RUN apt-get autoremove -y \
    && apt-get clean -y

# Install python packages with pip
RUN pip install --upgrade pip
ADD /requirements/ /tmp/requirements/
RUN pip install -r /tmp/requirements/pre-requirements.txt
RUN pip install -r /tmp/requirements/requirements.txt
#RUN pip install --proxy $PROXY -r /tmp/requirements/additional-reqs.txt
RUN pip install --upgrade https://github.com/ghislainv/deforestprob/archive/master.zip

# Create user
RUN useradd --create-home --home-dir /home/dockeruser --shell /bin/bash dockeruser
RUN adduser dockeruser sudo
RUN echo "dockeruser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# Create home with script
ADD run_ipython.sh /home/dockeruser
RUN chmod +x /home/dockeruser/run_ipython.sh
RUN chown dockeruser /home/dockeruser/run_ipython.sh

# Prepare notebook
EXPOSE 8888
USER dockeruser
RUN mkdir -p /home/dockeruser/notebooks
ENV HOME=/home/dockeruser
ENV SHELL=/bin/bash
ENV USER=dockeruser
VOLUME /home/dockeruser/notebooks
WORKDIR /home/dockeruser/notebooks

# Run jupyter notebook
CMD ["/home/dockeruser/run_ipython.sh"]

# End
