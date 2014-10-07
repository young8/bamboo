FROM centos:centos6

RUN yum install -y wget
RUN wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN rpm -ivh epel-release-6-8.noarch.rpm
RUN rm epel-release-6-8.noarch.rpm
RUN yum --enablerepo=epel update -y
RUN yum --enablerepo=epel install -y haproxy golang git mercurial  

ENV GOPATH /opt/go
RUN go get github.com/tools/godep
RUN go get -t github.com/smartystreets/goconvey
RUN git clone https://github.com/QubitProducts/bamboo.git /opt/go/src/github.com/QubitProducts/bamboo
WORKDIR /opt/go/src/github.com/QubitProducts/bamboo
RUN /opt/go/bin/godep restore
RUN go build
RUN mkdir /var/bamboo
RUN mv * /var/bamboo
WORKDIR /var/bamboo
RUN ls -l /var/bamboo
RUN rm -rf main Dockerfile Godeps api bamboo.go builder configuration qzk services /opt/go/src/github.com/*
RUN ls -l /var/bamboo

RUN mkdir -p /run/haproxy

EXPOSE 8000
EXPOSE 80

CMD ["--help"]
ENTRYPOINT ["/var/bamboo/bamboo"]
