FROM ubuntu:14.04
MAINTAINER Ross Ivantsiv <ross@proofpilot.com>

## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly).
RUN useradd docker \
    && mkdir /home/docker \
    && chown docker:docker /home/docker \
    && addgroup docker staff


## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

ENV R_BASE_VERSION 3.2.2

## Add RStudio binaries to PATH
ENV PATH /usr/lib/rstudio-server/bin/:$PATH

RUN apt-get update  && \
    apt-get -y dist-upgrade && \
    apt-get install -y software-properties-common && \
    echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" > /etc/apt/sources.list.d/ubuntu-cran.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    add-apt-repository -y ppa:marutter/rdev && \
    add-apt-repository -y ppa:opencpu/opencpu-1.5 && \
    apt-get update && \
    apt-get install -y \
    iputils-ping \
    iputils-tracepath \
    net-tools \
    telnet \
    curl \
    traceroute \
    dnsutils \
    nano \
    mc \
    ed \
    less \
    locales \
    vim-tiny \
    openssh-server \
    debianutils \
    wget \
    file \
    git \
    libapparmor1 \
    libedit2 \
    libcurl4-openssl-dev \
    libssl1.0.0 \
    libssl-dev \
    psmisc \
    python-setuptools \
    supervisor \
    sudo \
    ca-certificates \
    r-base=${R_BASE_VERSION}* \
    r-base-dev=${R_BASE_VERSION}* \
    r-recommended=${R_BASE_VERSION}* \
    r-cran-littler \
    opencpu \
    && echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
    && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
    && ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
    && ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
    && ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    && ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
    && install.r docopt \
    && VER=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
    && wget -q http://download2.rstudio.org/rstudio-server-${VER}-amd64.deb \
    && dpkg -i rstudio-server-${VER}-amd64.deb \
    && rm rstudio-server-*-amd64.deb \
    && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin \
    && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin \
    && wget https://github.com/jgm/pandoc-templates/archive/1.15.0.6.tar.gz \
    && mkdir -p /opt/pandoc/templates && tar zxf 1.15.0.6.tar.gz \
    && cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* \
    && mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates \
    && apt-get clean \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
    && rm -rf /var/lib/apt/lists/*

RUN /usr/sbin/a2ensite opencpu 2>&1 >/dev/null | grep -i  'error' || true

######### Some vagrant-related things ###############################################

ADD https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub /home/docker/.ssh/authorized_keys
RUN chown -R docker:docker /home/docker/.ssh
RUN chmod 0600 /home/docker/.ssh/authorized_keys
RUN chmod 0700 /home/docker/.ssh

ADD sudoers.d/01_docker /etc/sudoers.d/
RUN chmod 0400 /etc/sudoers.d/01_docker
RUN chown root:root /etc/sudoers.d/01_docker

RUN sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
RUN sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config
RUN sed -i "s/Defaults.*requiretty/Defaults \!requiretty/" /etc/sudoers

RUN mkdir /var/run/sshd

######################################################################################

## Ensure that if both httr and httpuv are installed downstream, oauth 2.0 flows still work correctly.
RUN echo '\n\
\n# Configure httr to perform out-of-band authentication if HTTR_LOCALHOST \
\n# is not set since a redirect to localhost may not work depending upon \
\n# where this Docker container is running. \
\nif(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { \
\n  options(httr_oob_default = TRUE) \
\n}' >> /etc/R/Rprofile.site

## A default user system configuration. For historical reasons,
## we want user to be 'rstudio', but it is 'docker' in r-base
RUN usermod -l rstudio docker \
  && usermod -m -d /home/rstudio rstudio \
  && groupmod -n rstudio docker \
  && git config --system user.name rstudio \
  && git config --system user.email rstudio@example.com \
  && git config --system push.default simple \
  && echo '"\e[5~": history-search-backward' >> /etc/inputrc \
  && echo '"\e[6~": history-search-backward' >> /etc/inputrc \
  && echo "rstudio:rstudio" | chpasswd


RUN mkdir -p /home/rstudio/r-ppv3 && \
    chown rstudio:rstudio /home/rstudio/r-ppv3 \
    && chmod g+w /home/rstudio/r-ppv3

## User config and supervisord for persistant RStudio session
COPY userconf.sh /usr/bin/userconf.sh
COPY add-students.sh /usr/local/bin/add-students
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor \
  && chgrp staff /var/log/supervisor \
  && chmod g+w /var/log/supervisor \
  && chgrp staff /etc/supervisor/conf.d/supervisord.conf

##########################################################################################


# Apache ports
EXPOSE 80
EXPOSE 443
EXPOSE 8004

# Rstudio
EXPOSE 8787

ENV TERM=xterm

##########################################################################################

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]



