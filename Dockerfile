FROM centos:centos6

RUN yum install -y -q wget && wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm 
RUN yum localinstall -y -q epel-release-6-8.noarch.rpm
RUN rm -f epel-release-6-8.noarch.rpm
RUN yum --enablerepo=epel update -y -q && yum --enablerepo=epel install -y -q haproxy golang git mercurial  

ENV GOPATH /opt/go
RUN go get github.com/tools/godep
RUN go get -t github.com/smartystreets/goconvey
RUN git clone https://github.com/QubitProducts/bamboo.git /opt/go/src/github.com/QubitProducts/bamboo
WORKDIR /opt/go/src/github.com/QubitProducts/bamboo
RUN /opt/go/bin/godep restore
RUN go build
RUN mkdir /var/bamboo && mv * /var/bamboo
WORKDIR /var/bamboo
RUN rm -rf main Dockerfile Godeps api bamboo.go builder configuration qzk services /opt/go/src/github.com/* /var/bamboo/config/development.json
RUN wget --directory-prefix=/var/bamboo/config/  https://raw.githubusercontent.com/bianchettim/bamboo/master/development.json 
RUN mkdir -p /run/haproxy && sed -i 's/^global$/global\n    ulimit-n    10240/g' /etc/haproxy/haproxy.cfg && ulimit -n 10240

EXPOSE 8000
EXPOSE 80

CMD ["--help"]
ENTRYPOINT service haproxy start && /var/bamboo/bamboo -config="/var/bamboo/config/development.json" -bind=":8000"
