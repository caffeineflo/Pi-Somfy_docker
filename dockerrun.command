docker container run -dit -v /home/pi/Pi-Somfy/data:/app/data --restart always --name pi-somfy -p 8080:80 --network=pi-net --ip=172.18.0.2 -t pi-somfy:v0.94
