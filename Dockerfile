#!/usr/bin/env bash
# docker-debian-jupyter
# Debian dockerfile with jupyter notebook

# Base image
FROM launcher.gcr.io/google/debian8:latest
MAINTAINER Ghislain Vieilledent <ghislain.vieilledent@cirad.fr>

# Export env settings
ENV TERM=xterm
ENV LC_ALL C.UTF-8
#ENV PROXY  http://10.168.209.73:8012
#RUN export http_proxy=$PROXY
#RUN export https_proxy=$PROXY
#RUN export ftp_proxy=$PROXY
#RUN echo "Acquire::http::proxy \"http://10.168.209.73:8012/\";" >> /etc/apt/apt.conf
#RUN echo "Acquire::https::proxy \"https://10.168.209.73:8012/\";" >> /etc/apt/apt.conf
#RUN echo "Acquire::ftp::proxy \"http://10.168.209.73:8012/\";" >> /etc/apt/apt.conf

# Install debian packages with apt-get
ADD apt-packages.txt /tmp/apt-packages.txt
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y
RUN xargs -a /tmp/apt-packages.txt apt-get install -y

# Clean-up
RUN apt-get autoremove -y
RUN apt-get clean -y

# Reconfigure locales
RUN dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN dpkg-reconfigure locales

# Virtual environment
#RUN pip install --proxy $PROXY virtualenv
#RUN /usr/local/bin/virtualenv /opt/jrc --distribute

# Install python packages with pip
ADD /requirements/ /tmp/requirements/
RUN pip install -r /tmp/requirements/pre-requirements.txt #--proxy $PROXY
RUN pip install -r /tmp/requirements/requirements.txt #--proxy $PROXY
#RUN /opt/jrc/bin/pip install --proxy $PROXY -r /tmp/requirements/additional-reqs.txt
RUN pip install https://github.com/ghislainv/deforestprob/archive/master.zip #--proxy $PROXY

# Install gdal
#RUN export CPLUS_INCLUDE_PATH=/usr/include/gdal
#RUN export C_INCLUDE_PATH=/usr/include/gdal
#RUN pip install --proxy $PROXY gdal

# Create user
RUN useradd --create-home --home-dir /home/jrc --shell /bin/bash jrc
#RUN chown -R jrc /opt/jrc
RUN adduser jrc sudo
RUN echo "jrc ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# Create home with script
ADD run_ipython.sh /home/jrc
RUN chmod +x /home/jrc/run_ipython.sh
RUN chown jrc /home/jrc/run_ipython.sh
#ADD .bashrc.template /home/jrc/.bashrc

# Prepare notebook
EXPOSE 8888
USER jrc
RUN mkdir -p /home/jrc/notebooks
ENV HOME=/home/jrc
ENV SHELL=/bin/bash
ENV USER=jrc
VOLUME /home/jrc/notebooks
WORKDIR /home/jrc/notebooks

# Run jupyter notebook
CMD ["/home/jrc/run_ipython.sh"]

