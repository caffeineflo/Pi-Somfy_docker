FROM alpine

ENV LANG C.UTF-8

# Copy data for add-on
COPY run.sh /

# Install requirements for add-on
RUN apk add --no-cache python3

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
        tar \
  && wget -O /tmp/pigpio.tar abyz.me.uk/rpi/pigpio/pigpio.tar \
  && tar -xf /tmp/pigpio.tar -C /tmp \
  && sed -i "/ldconfig/d" /tmp/PIGPIO/Makefile \
  && make -C /tmp/PIGPIO \
  && make -C /tmp/PIGPIO install \
  && rm -rf /tmp/PIGPIO /tmp/pigpio.tar \
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
# fix the way the shutter behaves in Home Assistant (do not gray out down button after pressing closed)
RUN sed -i -E 's/"position_topic": "somfy\/'\''\+shutterId\+'\''\/level\/set_state",\s//g;s/,\s"state_open":\s"100",\s"state_closed": "0"//g;s/\s"set_position_topic":\s"somfy\/'\''\+shutterId\+'\''\/level\/cmd",//g' /app/Pi-Somfy/mymqtt.py
RUN sed -i -e 's/pi\ =\ pigpio\.pi()/pi\ =\ pigpio\.pi("172.18.0.1")/g' /app/Pi-Somfy/operateShutters.py && sed -i -e 's/if\ sys\.version_info\[0\]\ <\ 3\:/return\ True\ # no need to start pigpiod inside docker, connecting to host instead!\n\ \ \ \ \ \ \ if\ sys\.version_info\[0\]\ <\ 3\:/g' /app/Pi-Somfy/operateShutters.py
WORKDIR /app/data

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
