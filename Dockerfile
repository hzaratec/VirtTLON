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

RUN sudo apt-get update
RUN sudo apt-get install -y net-tools
RUN sudo apt-get install wireless-tools
RUN sudo apt-get install libnl-3-200 libnl-genl-3-200 libnl-route-3-200
RUN apt-get install avahi-daemon avahi-discover libnss-mdns
RUN sudo apt-get install mongodb-server
RUN sudo apt-get install wget
RUN  cd /usr/local/lib
RUN wget http://www.antlr.org/download/antlr-4.5.3-complete.jar
RUN export CLASSPATH=".:/usr/local/lib/antlr-4.5.3-complete.jar:$CLASSPATH"
RUN alias antlr4='java -jar /usr/local/lib/antlr-4.5.3-complete.jar'
RUN alias grun='java org.antlr.v4.gui.TestRig'
#Se agregan los páquetes necesarios para que la imagen corra en modo ad hoc y con los programas, que se vayan agregando
COPY . /home/pi/TLON

#Instalación de Python 3.5 para el desarrollo de los scripts


WORKDIR /home/pi/TLON
#COPY Adhoc.py /home/pi/TLON/Adhoc.py
COPY batctl_2016.2-1_armhf.deb /home/pi/TLON/batctl_2016.2-1_armhf.deb
#COPY batman-adv-2016.2 /home/pi/TLON/batman-adv-2016.2

#Instalación de los paquetes batman.
RUN dpkg -i batctl_2016.2-1_armhf.deb
#CMD ["/bin/bash"]
#COPY /home/pi/TLON/Adhoc.py /home/pi/TLON/Adhoc.py
#CMD ["python3","home/pi/TLON/Adhoc.py"]
#CMD ["modprobe batman-adv"]
#RUN python3 Adhoc.py
#CMD ["batctl -v","/home/pi"]
#RUN batctl -v
