#!/bin/sh
#echo "Pi-Somfy container v0.8 (priv mode required for pigpiod)"
echo "Pi-Somfy container v0.93 (pigpiod via host))"
#/usr/bin/nohup /usr/local/bin/pigpiod -n localhost 1> /app/data/pigpiod.out 2>&1 &
/usr/bin/python3 /app/Pi-Somfy/operateShutters.py -a -m
