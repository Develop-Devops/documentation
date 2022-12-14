
Para crearnos una cuenta en CircleCI haremos uso de una cuenta en github, nos logueamos en nuestra cuenta de https://github.com/ o https://gitlab.com/:

![qownnotes-media-PXAaje](../../media/qownnotes-media-PXAaje.png)

## Github
![qownnotes-media-WtiMbO](../../media/qownnotes-media-WtiMbO.png)

Confirmamos el acceso

![qownnotes-media-YsZELs](../../media/qownnotes-media-YsZELs.png)


## Gitlab
![qownnotes-media-PfdGhQ](../../media/qownnotes-media-PfdGhQ.png)

Y procedemos a crearnos nuestra cuenta en https://circleci.com/

![qownnotes-media-IjUvuz](../../media/qownnotes-media-IjUvuz.png)

Nos dirigimos a sign UP y llenamos nuestros datos

![qownnotes-media-WHVmEs](../../media/qownnotes-media-WHVmEs.png)

En este punto es importante revisar nuestro correo donde nos enviaran el linkde verificación para nuestra cuenta:

![qownnotes-media-sQDgZx](../../media/qownnotes-media-sQDgZx.png)

Cuenta verificacada

![qownnotes-media-biNZPY](../../media/qownnotes-media-biNZPY.png)

## Gitlab
Procedmos a conectarnos con nuestro repositorio

![qownnotes-media-oyKasJ](../../media/qownnotes-media-oyKasJ.png)

Autorizamos en gitlab.com:

![qownnotes-media-rfzqpN](../../media/qownnotes-media-rfzqpN.png)

Una vez autorizado nos redirige a la pantalla de configuración donde elegiremos el repositorio al que le haremos el despliegue:

quedando finalmente asi:
![qownnotes-media-QXdHwE](../../media/qownnotes-media-QXdHwE.png)

Ahora iremos a Project Settings:

![qownnotes-media-yirwKv](../../media/qownnotes-media-yirwKv.png)

Configuration:

![qownnotes-media-rHzGVO](../../media/qownnotes-media-rHzGVO.png)

Add configuration source:

Eligimos la rama donde lo queremos poner y salvamos:

![qownnotes-media-UoDXrp](../../media/qownnotes-media-UoDXrp.png)

![qownnotes-media-mBzpZT](../../media/qownnotes-media-mBzpZT.png)

Agregamos el siguiente archivo en el `.circleci/config.yml` en nuestra rama y ponemos una sentencia de circleci, por ejemplo:

```
version: '2.1'
jobs:
  test:
    docker:
      - image: cimg/base:2022.11
    steps:
      - run:
          name: Building artifacts
          command: |
            echo "Hello"
    parallelism: 4
workflows:
  version: 2
  build_test_deploy:
    jobs:
      - test:
          filters:
            branches:
              only: 
                - main
```


![qownnotes-media-oFbRpa](../../media/qownnotes-media-oFbRpa.png)

Y vemos que ya esta corriendo en circleci

![qownnotes-media-eJyNKw](../../media/qownnotes-media-eJyNKw.png)

Aca esta el proceso corrido en circleci

![qownnotes-media-meuuBl](../../media/qownnotes-media-meuuBl.png)

