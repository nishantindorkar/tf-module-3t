#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo sed -i "38i\
server {\
  listen 80;\
  listen [::]:80;\
  server_name _;\
  location / {\
    proxy_pass http://$internal_lb_dns_name/student/;\
  }\
}\
" /etc/nginx/nginx.conf
sudo systemctl start nginx
sudo systemctl enable nginx