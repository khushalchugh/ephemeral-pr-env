#!/bin/bash
sudo yum update -y
sudo yum install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

echo "<h1>Ephemeral Server is Running Successfully</h1>" | sudo tee /usr/share/nginx/html/index.html