
# Seja bem-vindo ao repositório DNS em Docker Swarm!

Este projeto visa auxiliar na implementação de soluções de rede seguras, confiáveis e escaláveis com infraestrutura containerizada, utilizando Proxmox, Ubuntu Cloud-Image, Docker Swarm, Terraform, Ansible, PfSense, Pi-Hole e Unbound.

Wiki: https://github.com/zecaoliveira/dns-in-docker-swarm/wiki

### O que você encontrará aqui:

- Configurações de redes overlay para containers Docker: garanta a comunicação segura e eficiente entre seus containers, isolando-os em redes virtuais privadas.
- Implementação de firewalls e políticas de acesso: proteja seus containers contra acessos não autorizados e ataques cibernéticos.
- Utilização de volumes persistentes e seguros: armazene dados de forma confiável e persistente, mesmo em caso de falhas ou reinicializações dos containers.
- Criação de clusters Swarm resilientes: implemente alta disponibilidade para seus serviços críticos, minimizando o tempo de inatividade e a perda de dados.
- Orientações para a contratação de suporte especializado: obtenha o máximo de desempenho e segurança para sua solução com o suporte de empresas como a PiHole.

### Este projeto é ideal para:

- DevOps: aprimore suas habilidades em containerização, redes e segurança em Docker.
- Arquitetos de software: projete e implemente soluções de infraestrutura escaláveis e resilientes.
- Administradores de sistemas: gerencie e monitore clusters Docker Swarm de forma eficiente.
- Entusiastas de tecnologia: explore o potencial da containerização para simplificar e otimizar a gestão de infraestrutura. Construa sua Homelab usando o código aqui compartilhado e aplique em tempo real na rede da sua casa aumentando, por exemplo, a velocidade e a segurança da sua conexão de rede com a Internet.

### Comece sua jornada agora:

- Clone o repositório: https://github.com/zecaoliveira/dns-in-docker-swarm
- Explore o código: aprenda na prática como implementar soluções de rede segura e escalável com Docker Swarm.
- Contribua para o projeto: compartilhe seu conhecimento e ajude a comunidade a crescer.

Vamos ao que interessa: comandos de implementação.

1 - Criar um volume para armazenar os arquivos de configuração do Pi-Hole e do Unbound e adicionar ao script YML:
```
$ docker volume create pwu_data
```
![image](https://github.com/zecaoliveira/dns-in-docker-swarm/assets/42525959/3b8b3df0-4c26-46c2-9a5b-6c260c5e7051)

2 - Contrua a sua image Docker: https://github.com/zecaoliveira/dns-in-docker-swarm/blob/main/Dockerfile
```
$ docker build -t piholewunbound:v3 .
```
3 - Ajustar o script YAML com as informações da sua infraestrutura:

```

```

3 - Implementar (deploy) as configurações do script YML usando o comando abaixo:
```
$ docker stack deploy --compose-file=docker-compose.yaml dns
```
3 - Para verificar se está tudo OK:

> Observação: o intuito é aprender os métodos de controle e troubleshooting através da CLI. Fique a vontade para usar o Portainer por exemplo.
> Link: https://docs.portainer.io/start/install-ce/server/swarm/linux

3.1 - Serviços:
```
$ docker service ls
```
3.2 - Identificar em qual nó o serviço está sendo executado naquele momento
```
$ docker service ps <nome do serviço>
```
![image](https://github.com/zecaoliveira/dns-in-docker-swarm/assets/42525959/7025fa0f-2928-47a1-989a-ce12e9e566d0)



### Observações importantes:

Este projeto serve como base para implementações customizadas. Adapte-o de acordo com suas necessidades específicas.
Mantenha-se atualizado sobre as melhores práticas de segurança em Docker e redes containerizadas.
Desenvolva suas habilidades em DevOps e conquiste as melhores oportunidades no mercado!

Junte-se à comunidade e vamos construir soluções de rede inovadoras e eficientes juntos!

### Crédito e Referências:

Links:

- https://docs.pi-hole.net/guides/dns/unbound/
- https://unbound.docs.nlnetlabs.nl/en/latest/
- https://docs.github.com/pt/communities/setting-up-your-project-for-healthy-contributions/adding-a-license-to-a-repository
- https://opensource.guide/pt/legal/#:~:text=Se%20voc%C3%AA%20est%C3%A1%20iniciando%20do,o%20aviso%20de%20direitos%20autorais.
- https://github.com/JamesTurland/JimsGarage/tree/main/Unbound
- https://github.com/JamesTurland/JimsGarage/tree/main/Terraform
- https://docs.docker.com/engine/swarm/
- https://cloud-images.ubuntu.com/noble/current/
