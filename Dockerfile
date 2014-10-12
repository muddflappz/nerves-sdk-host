from ubuntu:12.04

ENV HOME /root
ENV http_proxy http://192.168.1.10:28000

# install the development packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils ; \
	DEBIAN_FRONTEND=noninteractive apt-get -y upgrade ; \
	DEBIAN_FRONTEND=noninteractive apt-get -y install  \
	autoconf \
	automake \
	bc \
	binutils-dev \
	bison \
	build-essential \
	chrpath \
	curl \
	debconf-utils \
	dropbear \
	elfutils \
	emacs \
	exuberant-ctags \
	firefox \
	flex \
	gawk \
	gettext \
	git \
	gitk \
	git-el \
	global \
	libtool \
	lxterminal \
	man \
	ncurses-dev \
	obconf \
	obmenu \
	openbox \
	openssh-client \
	python \
	python-dev \
	python-pip \
	python-software-properties \
	realpath \
	screen \
	sudo \
	vim \
	wget \
	vnc4server \
	xsltproc \
	whiptail \
	zip \
	zlib1g-dev

# install i386 modules
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install  \
	gcc-multilib \
	g++-multilib \
	zlib1g:i386

# make bash the system default shell
RUN echo "dash dash/sh boolean false" | debconf-set-selections 
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# set up locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

############# Supervisor ##############
# install supervisor
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install supervisor
RUN mkdir -p /var/log/supervisor
RUN rm /etc/supervisor/supervisord.conf
ADD supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD supervisor/dropbear.conf /etc/supervisor/conf.d/dropbear.conf

#################################################################################

# set up the nerves user
RUN useradd -m -s /bin/bash nerves ; \
	usermod -a -G sudo nerves ; \
	echo "nerves:nerves" | chpasswd

ENV HOME /home/nerves
ENV http_proxy ""

RUN mkdir ~nerves/.nerves-cache ; \
    chown nerves:nerves ~nerves/.nerves-cache ; \
    sudo -i -u nerves git clone https://github.com/nerves-project/nerves-sdk.git

# clean up
RUN apt-get clean

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
