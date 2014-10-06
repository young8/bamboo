FROM centos:centos6

RUN yum update -y
RUN yum install -y haproxy 
RUN yum install -y golang-src golang golang-pkg-bin-linux-amd64 golang-pkg-linux-amd64 
RUN yum install -y perl-Error perl-Git git mercurial

ENV GOPATH /opt/go
RUN go get github.com/tools/godep
RUN go get -t github.com/smartystreets/goconvey

RUN git clone https://github.com/QubitProducts/bamboo.git

ADD . /opt/go/src/github.com/QubitProducts/bamboo
WORKDIR /opt/go/src/github.com/QubitProducts/bamboo
RUN /opt/go/bin/godep restore
RUN go build
RUN ln -s /opt/go/src/github.com/QubitProducts/bamboo /var/bamboo

RUN mkdir -p /run/haproxy

EXPOSE 8000
EXPOSE 80

CMD ["--help"]
ENTRYPOINT ["/var/bamboo/bamboo"]
