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
RUN git clone https://github.com/QubitProducts/bamboo.git
ADD . /opt/go/src/github.com/QubitProducts/bamboo
RUN rm -rf bamboo 

WORKDIR /opt/go/src/github.com/QubitProducts/bamboo
RUN /opt/go/bin/godep restore
RUN go build
ADD /opt/go/src/github.com/QubitProducts/bamboo/bamboo /var/bamboo/
ADD /opt/go/src/github.com/QubitProducts/bamboo/config /var/bamboo/
ADD /opt/go/src/github.com/QubitProducts/bamboo/webapp /var/bamboo/
ADD /opt/go/src/github.com/QubitProducts/bamboo/*.js* /var/bamboo/
ADD /opt/go/src/github.com/QubitProducts/bamboo/Procfile /var/bamboo/
ADD /opt/go/src/github.com/QubitProducts/bamboo/LICENSE /var/bamboo/
ADD /opt/go/src/github.com/QubitProducts/bamboo/README* /var/bamboo/

WORKDIR /var/bamboo
RUN rm -rf /opt/go/src/github.com/*
RUN mkdir -p /run/haproxy

EXPOSE 8000
EXPOSE 80

CMD ["--help"]
ENTRYPOINT ["/var/bamboo/bamboo"]
