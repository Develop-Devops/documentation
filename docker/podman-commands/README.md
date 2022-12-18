podman
======

```
apt update 
apt install podman container-tools -y
```
`cat /etc/containers/registries.conf.d/shortnames.conf`

![qownnotes-media-RFhBHV](media/qownnotes-media-RFhBHV.png)

```
podman run --restart always -dt -p 8080:80/tcp docker.io/library/httpd
podman ps -l
```

```
podman images
podman image ls
```
```
podman search ubuntu
podman logs -l
podman top -l
podman stop -l
podman ps -a
podman rm -l
```

```
podman untag
```

`podman build -t fpm-personal .`

https://podman.io/getting-started/installation

@podman
@docker