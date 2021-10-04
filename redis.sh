#!/bin/bash

#echo  "bind 127.0.0.1 ::" >> /etc/redis/sentinel.conf

#echo "port 16379" >> /etc/redis/sentinel.conf

#echo "sentinel monitor redis-cluster 172.17.0.2 6379 2" >> /etc/redis/sentinel.conf

#echo "sentinel down-after-milliseconds redis-cluster 5000" >> /etc/redis/sentinel.conf

#echo "sentinel failover-timeout redis-cluster 10000" >> /etc/redis/sentinel.conf

#sed -i 's/daemonize no/daemonize yes/g' >> /etc/redis/sentinel.conf

#echo "pidfile /var/run/redis/sentinel.pid" >> /etc/redis/sentinel.conf

#echo "dir /var/redis"


touch /etc/systemd/system/redis.service

tee /etc/systemd/system/redis.service << EOF

[Unit]
Description=Redis 
After=network.target

[Service]
Type=forking
User=redis
Group=daemon
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=always

[Install]
WantedBy=multi-user.target

EOF

 systemctl start redis.service

 systemctl enable redis.service


touch /etc/systemd/system/sentinel.service

tee /etc/systemd/system/sentinel.service << EOF

[Unit]
Description=Redis-Sentinel
After=network.target

[Service]
Type=forking
PIDFile=/var/run/redis/sentinel.pid
ExecStart=/usr/local/bin/redis-server /etc/redis/sentinel.conf --sentinel
ExecStop=/bin/kill -s TERM $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target


EOF

#systemctl start sentinel.service
#systemctl enable sentinel.service
