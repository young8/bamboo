FROM centos:centos6
RUN yum install -y -q wget && wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && yum localinstall -y -q epel-release-6-8.noarch.rpm && rm -f epel-release-6-8.noarch.rpm && yum --enablerepo=epel update -y -q && yum --enablerepo=epel install -y -q haproxy golang git mercurial  

ENV GOPATH /opt/go
RUN go get github.com/tools/godep && go get -t github.com/smartystreets/goconvey
RUN git clone https://github.com/QubitProducts/bamboo.git /opt/go/src/github.com/QubitProducts/bamboo
WORKDIR /opt/go/src/github.com/QubitProducts/bamboo
RUN /opt/go/bin/godep restore && go build
RUN mkdir /var/bamboo && mv * /var/bamboo && rm -rf /var/bamboo/main /var/bamboo/Dockerfile /var/bamboo/Godeps /var/bamboo/api /var/bamboo/bamboo.go /var/bamboo/builder /var/bamboo/configuration /var/bamboo/qzk /var/bamboo/services /opt/go/src/github.com/* /var/bamboo/config/development.json
RUN wget --directory-prefix=/var/bamboo/config/  https://raw.githubusercontent.com/bianchettim/bamboo/master/development.json 
RUN mkdir -p /run/haproxy && sed -i 's/^global$/global\n    ulimit-n    10240/g' /etc/haproxy/haproxy.cfg && ulimit -n 10240

EXPOSE 8000
EXPOSE 80

CMD ["--help"]
ENTRYPOINT service haproxy start && /var/bamboo/bamboo -config="/var/bamboo/config/development.json" -bind=":8000"

