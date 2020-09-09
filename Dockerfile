#
# Dockerfile for hubot
#

FROM alpine:3.12

ENV ANSIBLE_VERSION 2.8.13
ENV ANSIBLE_LINT_VERSION 4.2.0

RUN apk --update --no-cache add \
        ca-certificates \
        git \
        openssh-client \
        openssl \
		python3 \
        rsync \
        sshpass \
		py3-pip

RUN apk --update add --virtual \
        .build-deps \
		python3-dev \
		libffi-dev \
        openssl-dev \
        build-base \
    && pip install --upgrade \
        pip \
        cffi \
	&& pip install \
        ansible==${ANSIBLE_VERSION} \
        ansible-lint==${ANSIBLE_LINT_VERSION} \
    && apk del \
        .build-deps

ENV HUBOT_NAME=Hubot
ENV HUBOT_ADAPTER=slack
ENV HUBOT_DESCRIPTION=$HUBOT_NAME-$HUBOT_ADAPTER
ENV HUBOT_SLACK_TOKEN=

#增加时区
RUN set -xe \
    && apk add --update nodejs nodejs-npm \
    && apk add tzdata \
    && apk add --no-cache bash \
        bash-doc \
        bash-completion \
        sudo \
    && apk add --no-cache bzip2-dev \
        coreutils dpkg-dev dpkg expat-dev \
        findutils gcc gdbm-dev libc-dev libnsl-dev libtirpc-dev \
        linux-headers make ncurses-dev pax-utils readline-dev \
        sqlite-dev tcl-dev tk tk-dev util-linux-dev xz-dev zlib-dev \
    && apk add git curl \
    && rm -rf /var/cache/apk/* \
    && npm install -g yo generator-hubot \
    && adduser -s /bin/sh -D hubot \
    && echo "hubot ALL=(ALL) ALL" >> /etc/sudoers \
    && mkdir /etc/ansible \
    && echo -e """\
\n\
Host *\n\
    StrictHostKeyChecking no\n\
    UserKnownHostsFile=/dev/null\n\
""" >> /etc/ssh/ssh_config

USER hubot
WORKDIR /home/hubot

RUN set -xe \
    && yo hubot --name $HUBOT_NAME \
                --description $HUBOT_DESCRIPTION \
                --adapter $HUBOT_ADAPTER \
                --defaults \
    && npm install --save hubot-$HUBOT_ADAPTER \
                          htmlparser \
                          moment \
                          querystring \
                          soupselect \
                          underscore \
                          underscore.string \
                          url \
                          hubot-grafana \
                          hubot-script-shellcmd \
                          hubot-jenkins-enhanced \
                          hubot-auth \
                          hubot-slack-jenkins-chatops \
    && sed -i -r 's/^\s+#//' scripts/example.coffee

COPY ./ansible.cfg .ansible.cfg

VOLUME /home/hobot \
       /usr/local/bin \
       /etc/ansible
EXPOSE 8080

CMD ["./bin/hubot", "--adapter", "slack"]

