FROM ubuntu:14.04


ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get dist-upgrade -y --no-install-recommends && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository -y ppa:tsung/daily && \
    apt-get update && \
    apt-get install -y --no-install-recommends tsung

RUN apt-get install -y --no-install-recommends openssh-server gnuplot libtemplate-perl
RUN ssh-keygen -N "" -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
    echo "StrictHostKeyChecking no" >> /root/.ssh/config && \
    echo "UserKnownHostsFile /dev/null" >> /root/.ssh/config

EXPOSE 22

# EPMD port: http://www.erlang.org/doc/man/epmd.html#environment_variables
EXPOSE 4369
ENV ERL_EPMD_PORT=4369

# mount a location on the disk to access the test scripts
RUN mkdir -p /usr/local/tsung
VOLUME ["/usr/local/tsung"]


EXPOSE 9001-9050
#
# make sure inet_dist_listen_* properties are available when Erlang runs
#
RUN sed -i.bak s/"64000"/"9001"/g /usr/bin/tsung
RUN sed -i.bak s/"65500"/"9050"/g /usr/bin/tsung
RUN printf "[{kernel,[{inet_dist_listen_min,9001},{inet_dist_listen_max,9050}]}]. \n\n" > /root/sys.config
RUN sed -i.bak s/"erlexec\""/"erlexec\" -config \/root\/sys"/g /usr/bin/erl

COPY tsung-runner.sh /usr/bin/tsung-runner
RUN chmod +x /usr/bin/tsung-runner

ENTRYPOINT ["tsung-runner"]
