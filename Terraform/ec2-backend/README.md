# ecs_launch_configuration

Esta es la configuración actual que tengo para ecs_launch_configuration. Esta ya ha empezado a estar en desuso por aws.

```
resource "aws_launch_configuration" "ecs_launch_configuration" {
    depends_on = [ aws_security_group.default-ecs ]
    image_id = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    associate_public_ip_address = false
    iam_instance_profile = aws_iam_instance_profile.this.id
    key_name = var.key_name
    security_groups = [ aws_security_group.default-ecs.id ]
    root_block_device {
        volume_size = 50
        volume_type = "gp2"
    }

    user_data = data.template_file.ecs_instance.rendered
}
```

# ecs_launch_template

El equivalente para la configuración anterior sería asi

```
resource "aws_launch_template" "ecs_launch_template" {
    depends_on = [ aws_security_group.default-ecs ]
    image_id = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type_template
    
    network_interfaces {
        associate_public_ip_address = false
        security_groups = concat(
            [aws_security_group.default-ecs.id],
        )
    }
    iam_instance_profile {
        name = aws_iam_instance_profile.this.id
    }

    key_name = var.key_name
    
    block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
            volume_size = 50
            volume_type = "gp2"
        }
    }

    user_data = base64encode(data.template_file.ecs_instance.rendered)
}
```

# user_data
La configuración actual es para que el autoscalling group se una a un cluster de ecs en aws. Dejo algunos detalles por si les es útil en sus despliegues

user_data se usa para ejecutar un commando o script al inicio del servidor, en este caso usamos un comando q con la tipo de maquina virtual se conectará al cluster de ecs:

este es el contenido del script que se ejecutará
```
#!/bin/bash

# ECS config
{
  echo "ECS_CLUSTER=${ecs_cluster}"
} >> /etc/ecs/ecs.config

start ecs

echo "Done"
```

En mi caso estaré usando ambas configuraciones hasta