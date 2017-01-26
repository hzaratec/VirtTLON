FROM resin/rpi-raspbian:jessie
#Imagen base pie@piesweb.co.uk
MAINTAINER Henry <hzaratec@unal.edu.co.>

ENV PYTHON_VERSION 3.5.2

RUN apt-get update && apt-get install -y -qq curl \
    build-essential \
    libncursesw5-dev \
    libgdbm-dev \
    libc6-dev \
    zlib1g-dev \
    libsqlite3-dev \
    tk-dev \
    libssl-dev \
    openssl \
    file \
    && curl -sSLk "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz" |tar xJ -C /tmp/ \
    && cd "/tmp/Python-$PYTHON_VERSION" \
    && ./configure --enable-shared \
    && make \
    && mkdir tmp_install \
    && make install DESTDIR=tmp_install \
    && for F in $(find tmp_install -exec file {} \; | grep "executable" | grep ELF | grep "not stripped" | cut -f 1 -d :); do \
            [ -f $F ] && strip --strip-unneeded $F; \
        done \
    && for F in $(find tmp_install -exec file {} \; | grep "shared object" | grep ELF | grep "not stripped" | cut -f 1 -d :); do \
            [ -f $F ] && if [ ! -w $F ]; then chmod u+w $F && strip -g $F && chmod u-w $F; else strip -g $F; fi \
        done \
    && for F in $(find tmp_install -exec file {} \; | grep "current ar archive" | cut -f 1 -d :); do \
            [ -f $F ] && strip -g $F; \
        done \
    && find tmp_install \( -type f -a -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' + \
    && find tmp_install \( -type d -a -name test -o -name tests \) | xargs rm -rf \
    && $(cd tmp_install; cp -R . /) \
    && /sbin/ldconfig \
    && curl -SLk 'https://bootstrap.pypa.io/get-pip.py' | python3 \
    && find /usr/local \( -type f -a -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' + \
    && find /usr/local \( -type d -a -name test -o -name tests \) | xargs rm -rf \
    && rm -rf "/tmp/Python-$PYTHON_VERSION" \
    && apt-get -qq -y --purge remove \
        build-essential \
        libncursesw5-dev \
        libgdbm-dev \
        libc6-dev \
        zlib1g-dev \
        libsqlite3-dev \
        tk-dev \
        libssl-dev \
        openssl \
        file \
    && apt-get -qq -y autoremove \
    && apt-get -qq -y clean \
    && rm /var/lib/apt/lists/* -Rf \
    && cd /usr/local/bin \
    && ln -s easy_install-3.5 easy_install \
    && ln -s idel3 idle \
    && ln -s pydoc3 pydoc \
    && ln -s python3 python \
    && ln -s python3-config python-config
#Instalacion de paquetes basicos
RUN sudo apt-get update

#Paquetes necesarios para dotar al contenedor del modo ad hoc y control de interfaces wlan, eth
RUN sudo apt-get install -y net-tools\
    wireless-tools\
    libnl-3-200 libnl-genl-3-200 libnl-route-3-200\
    avahi-autoipd\
    iproute2


# Instalacion de base de datos y elementos basicos para el contenedor
RUN  apt-get install mongodb-server
RUN  python -m pip install pymongo
RUN  apt-get install build-essential python-dev
RUN  apt-get install -y python-dev\
     vim\
     wget\
     git

#Instalacion de antlr

RUN apt-get install oracle-java8-jdk
RUN pip install antlr4-python3-runtime
RUN wget http://www.antlr.org/download/antlr-4.5.3-complete.jar
#ENV antlr4="java -jar /antlr-4.5.3-complete.jar:$CLASSPATH"
#ENV CLASSPATH=".:/antlr-4.5.3-complete.jar:$CLASSPATH"
#Se agregan los páquetes necesarios para que la imagen corra en modo ad hoc y con los programas, que se vayan agregando
COPY . /home/pi/TLON

#Instalación de Python 3.5 para el desarrollo de los scripts

WORKDIR /home/pi/TLON
COPY batctl_2016.2-1_armhf.deb /home/pi/TLON/batctl_2016.2-1_armhf.deb
RUN dpkg -i batctl_2016.2-1_armhf.deb
COPY iputils-ping_20101006-1+b2_armhf.deb /home/pi/TLON/iputils-ping_20101006-1+b2_armhf.deb
RUN dpkg -i iputils-ping_20101006-1+b2_armhf.deb


#Instalación de los paquetes batman.
#CMD bash
#CMD ["/","export CLASSPATH=".: /antlr-4.5.3-complete.jar:$CLASSPATH""]
#CMD ["/",alias antlr4='java -jar /antlr-4.5.3-complete.jar'"]
#CMD ["/",alias grun='java org.antlr.v4.gui.TestRig'"]
