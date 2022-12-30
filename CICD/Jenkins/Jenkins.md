# Install Jenkins
```

sudo apt update && sudo apt install openjdk-11-jdk nginx -y

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update && sudo apt install jenkins -y

snap install certbot --classic

sudo systemctl status jenkins

```
![qownnotes-media-yEAMoF](../../media/qownnotes-media-yEAMoF.png)

`sudo systemctl enable --now jenkins`


## Cofigure virtualhost
```
cat << EOF > /etc/nginx/sites-available/jenkins

server {

        server_name jenkins.weweb.com;
        location /health/ {
                return 200 "ok";
                add_header Content-Type text/plain;

        }
        location / {

                proxy_set_header X-Real-IP  \$remote_addr;
                proxy_set_header X-Forwarded-For \$remote_addr;
                proxy_set_header Host \$host;
                proxy_set_header X-Forwarded-Proto \$scheme;
                proxy_pass          http://localhost:8080;

        }

    listen [::]:80;
    listen 80;

}

EOF
```

ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
nginx -t


