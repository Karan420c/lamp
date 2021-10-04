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

echo "slaveof 172.17.0.2 6379"  >>  /etc/redis/redis.conf
 
 systemctl start redis.service

 systemctl enable redis.service

touch /etc/systemd/system/sentinel.service

tee /etc/systemd/system/sentinel.service << EOF

[Unit]
Description=Redis-Sentinel
After=network.target

[Service]
Type=forking
PIDFile=/var/run/redis-sentinel.pid/
ExecStart=/usr/local/bin/redis-server /etc/redis/sentinel.conf --sentinel
ExecStop=/bin/kill -s TERM $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target

EOF

sed -i  's/daemonize no/daemonize yes/g' /etc/redis/sentinel.conf

sed -i  's/port 26379/port 16381/g'  /etc/redis/sentinel.conf

sed -i  's/sentinel monitor mymaster 127.0.0.1 6379 2/sentinel monitor redis-cluster 172.17.0.2 6379 2/g' /etc/redis/sentinel.conf

sed -i  's/sentinel down-after-milliseconds mymaster 30000/sentinel down-after-milliseconds redis-cluster 5000/g' /etc/redis/sentinel.conf

sed -i  's/sentinel parallel-syncs mymaster 1/sentinel parallel-syncs redis-cluster 1/g' /etc/redis/sentinel.conf

sed -i  's/sentinel failover-timeout mymaster 180000/sentinel failover-timeout redis-cluster 10000/g' /etc/redis/sentinel.conf


sed -i 's/logfile ""/#logfile ""/g' /etc/redis/sentinel.conf

echo "logfile /var/log/redis/sentinel.log" >> /etc/redis/sentinel.conf


echo "vm.overcommit_memory=1" >> /etc/sysctl.conf

echo "net.core.somaxconn=65535" >>  /etc/sysctl.conf

systemctl start sentinel.service
systemctl enable sentinel.service
