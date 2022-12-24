Loguearse con un usuario distinto a root en mi caso utilizaré ubuntu

```
mkdir myagent && cd myagent
wget https://vstsagentpackage.azureedge.net/agent/2.213.2/vsts-agent-linux-x64-2.213.2.tar.gz
tar zxvf vsts-agent-linux-x64-2.213.2.tar.gz
./config.sh
```

# Server URL
https://dev.azure.com/{your-organization}

# Personal token
![qownnotes-media-ekDPgA](../../media/qownnotes-media-ekDPgA.png)


# Pool
Eliges el pool al que quieras agregarlo, en mi caso agregue uno llamado mypool

Una vez configurado correr ./run.sh y comenzamos a ver al servicio escuchando por nuevos jobs:

![qownnotes-media-twQWyR](../../media/qownnotes-media-twQWyR.png)

# Pipeline

Una vez configurado el agente procedemos a crear un pipeline:

## Crear repositorio

Nos dirigimos a nuestra organización -> Repos -> New Repository

![qownnotes-media-kCTzps](../../media/qownnotes-media-kCTzps.png)

Crearemos uno llamado tester

![qownnotes-media-WHxJZf](../../media/qownnotes-media-WHxJZf.png)


## Build

Para facilitarnos el trabajo podemos ir al botón Set up Build que aparece en el propio repositorio:

![qownnotes-media-lQrYKL](../../media/qownnotes-media-lQrYKL.png)

y nos lleva a una pantalla como esta:

![qownnotes-media-eUEsmj](../../media/qownnotes-media-eUEsmj.png)

Damos starter pipeline dado de que hasta el momento no disponemos de uno:
![qownnotes-media-tbreWA](../../media/qownnotes-media-tbreWA.png)

y rapidamente nos genera un pipeline de ejemplo

En nuestro caso cambiaremos el pool por el creado por nosotros

cambiamos:
```
pool:
  vmImage: ubuntu-latest
```

por

`pool: mypool`

agremosle una pequeña dificultad y de paso una herramienta q nos será util (variables). Si notan en el panel hay un apartado variable

![qownnotes-media-kbsttg](../../media/qownnotes-media-kbsttg.png)

Agregamos una nueva


