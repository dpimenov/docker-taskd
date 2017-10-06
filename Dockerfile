FROM ubuntu:16.04

ENV TASKDDATA /var/taskd

RUN apt-get update && \
    apt-get install -y task taskd

RUN mkdir -p $TASKDDATA
RUN taskd init

ADD vars /usr/share/taskd/pki/vars

RUN cd /usr/share/taskd/pki && \
    ./generate && \
    cp client.cert.pem $TASKDDATA && \
    cp client.key.pem $TASKDDATA && \
    cp server.cert.pem $TASKDDATA && \
    cp server.key.pem $TASKDDATA && \
    cp server.crl.pem $TASKDDATA && \
    cp ca.cert.pem $TASKDDATA

RUN taskd config --force client.cert $TASKDDATA/client.cert.pem && \
    taskd config --force client.key $TASKDDATA/client.key.pem && \
    taskd config --force server.cert $TASKDDATA/server.cert.pem && \
    taskd config --force server.key $TASKDDATA/server.key.pem && \
    taskd config --force server.crl $TASKDDATA/server.crl.pem && \
    taskd config --force ca.cert $TASKDDATA/ca.cert.pem

RUN cd $TASKDDATA && \
    taskd config --force log $PWD/taskd.log && \
    taskd config --force pid.file $PWD/taskd.pid && \
    taskd config --force server taskd:53589

RUN taskdctl start
ENTRYPOINT taskd server

EXPOSE 53589
