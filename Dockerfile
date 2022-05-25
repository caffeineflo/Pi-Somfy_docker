FROM zinen2/alpine-pigpiod:latest

ENV LANG C.UTF-8

# Copy data for add-on
COPY run.sh /

# Install requirements for add-on
RUN apk add --no-cache python3

RUN apk add --no-cache py3-pip

RUN pip3 install --upgrade pip

RUN set -xe \
    && apk add --no-cache -Uu --virtual .build-dependencies python3-dev libffi-dev openssl-dev build-base musl \
    && pip3 install --no-cache --upgrade pyserial RPi.GPIO \
    && apk del --purge .build-dependencies \
    && apk add --no-cache --purge curl ca-certificates musl wiringpi \
    && rm -rf /var/cache/apk/* /tmp/*


RUN apk add --no-cache --virtual .build-deps \
        gcc \
        make \
        musl-dev \
        unzip \
  && wget -O /tmp/pigpio.zip https://github.com/joan2937/pigpio/archive/master.zip \
  && unzip /tmp/pigpio.zip -d /tmp \
  && sed -i "/ldconfig/d" /tmp/pigpio-master/Makefile \
  && make -C /tmp/pigpio-master \
  && make -C /tmp/pigpio-master install \
  && rm -rf /tmp/pigpio-master /tmp/pigpio.zip \
  && apk del .build-deps

# Install requirements for add-on
RUN apk add --no-cache git \
    python3 

RUN apk add --no-cache --virtual .build-deps \
        gcc \
        g++ \
		python3-dev \
  && pip3 install requests ephem configparser Flask paho-mqtt \
  && apk del .build-deps
  

 
WORKDIR /app
RUN git clone https://github.com/Nickduino/Pi-Somfy
RUN sed -i 's/sudo\s//g' /app/Pi-Somfy/operateShutters.py
WORKDIR /app/data

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

EXPOSE 80
VOLUME /app/data
