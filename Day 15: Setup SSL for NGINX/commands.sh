# Update the system
sudo yum update -y
# Install nginx
sudo yum install nginx -y
# Enable and start nginx service
sudo systemctl enable nginx
sudo systemctl start nginx
# Check status
sudo systemctl status nginx
sudo mkdir -p /etc/nginx/ssl
sudo mv /tmp/nautilus.crt /etc/nginx/ssl/
sudo mv /tmp/nautilus.key /etc/nginx/ssl/
sudo chmod 600 /etc/nginx/ssl/nautilus.key
sudo chmod 644 /etc/nginx/ssl/nautilus.crt
# modify your nginx.conf file
vi /etc/nginx/nginx.conf
sudo nginx -t
sudo systemctl reload nginx
echo "Welcome!" | sudo tee /usr/share/nginx/html/index.html
