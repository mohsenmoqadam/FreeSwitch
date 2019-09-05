FROM debian:10

LABEL maintainer="Mohsen Moqadam <MohsenMoqadam@yahoo.com>"

# Install Deps.
RUN apt-get update && \
    apt-get install -yq gnupg2 wget lsb-release && \
    wget -O - https://files.freeswitch.org/repo/deb/debian-release/fsstretch-archive-keyring.asc | apt-key add - && \
    echo "deb http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list && \
    echo "deb-src http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list && \
    apt-get update && \
    apt-get build-dep freeswitch -y

# Setup Supervisord
RUN apt-get update && \
    apt-get install -y supervisor && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/supervisor/conf.d
COPY supervisor.conf /etc/supervisor.conf
COPY sup_freeswitch.conf /etc/supervisor/conf.d/freeswitch.conf

# Install FreeSwitch
WORKDIR /tmp/build
RUN git clone https://freeswitch.org/stash/scm/fs/freeswitch.git -bv1.10 freeswitch && \
    cd freeswitch && \
    git config pull.rebase true && \
    ./bootstrap.sh -j && \
    ./configure && \
    make && \
    make install && \
    sed -i 's/\#event_handlers\/mod_erlang_event/event_handlers\/mod_erlang_event/g' modules.conf && \
    sed -i 's/\#languages\/mod_python/languages\/mod_python/g' modules.conf && \
    make mod_erlang_event && \
    make mod_erlang_event-install && \
    make mod_python && \
    make mod_python-install && \
    rm freeswitch

# Upload FreeSwitch Configurations
COPY conf /usr/local/freeswitch/conf
COPY scripts /usr/local/freeswitch/scripts
RUN cd /usr/local/lib/python2.7/dist-packages && \
    ln -s /usr/local/freeswitch/scripts/pyPack .

# Install SIPp
RUN apt-get install libpcap-dev -y && \
    apt-get install libsctp-dev -y && \
    git clone https://github.com/SIPp/sipp.git && \
    cd sipp && \
    ./build.sh --with-pcap  --with-sctp --with-openssl && \
    cp sipp /usr/local/bin/ && \
    rm sipp
COPY SIPp /usr/local/sipp/scenarios    

# Install Required Python Modules
RUN apt-get install python-pip -y && \
    pip install PyJWT 

# Install VIM
RUN apt-get install vim -y

WORKDIR /usr/local/freeswitch/bin
CMD ["supervisord", "-c", "/etc/supervisor.conf"]
