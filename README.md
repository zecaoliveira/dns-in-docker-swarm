
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

2 - Contrua a sua imagem Docker: https://github.com/zecaoliveira/dns-in-docker-swarm/blob/main/Dockerfile

> Nota: estou executando estes comandos em um Cluster Docker Swarm com 3 servidores: um controller e dois nodes!!!
> 
> Mérito do ótimo vídeo do Rob with Tech: https://www.youtube.com/watch?v=IqsPH6oXy8c&t=16s
>
> Repositório: https://github.com/robwithtech/homelab

```
$ docker build -t piholewunbound:v3 .
```
3 - Ajustar o script YAML com as informações da sua infraestrutura: https://github.com/zecaoliveira/dns-in-docker-swarm/blob/main/docker-compose.yaml

4 - Implementar (deploy) as configurações do script YAML usando o comando abaixo:
```
$ docker stack deploy --compose-file=docker-compose.yaml dns
```
4 - Para verificar se está tudo OK:

> Observação: o intuito é aprender os métodos de controle e troubleshooting através da CLI. Fique a vontade para usar o Portainer por exemplo.
> Link: https://docs.portainer.io/start/install-ce/server/swarm/linux

4.1 - Serviços:
```
$ docker service ls
```
![image](https://github.com/zecaoliveira/dns-in-docker-swarm/assets/42525959/84203ab6-4e32-4ebb-8849-ef066e6797ef)

4.2 - Identificar em qual nó o serviço está sendo executado naquele momento
```
$ docker service ps <nome do serviço>
```
![image](https://github.com/zecaoliveira/dns-in-docker-swarm/assets/42525959/1146229f-f9a0-4b83-8d66-e02336d6f5ec)

4.3 - Acessar o bash do container:
```
$ docker exec -it <nome do container> bash
```
![image](https://github.com/zecaoliveira/dns-in-docker-swarm/assets/42525959/3ba30924-080f-4c57-b754-fd4823871a39)

4.4 - Teste de conexão e resolução de nomes usando o Unbound:
```
root@piholewunbound:/# dig www.globo.com @127.0.0.1 -p 5335
```

![image](https://github.com/zecaoliveira/dns-in-docker-swarm/assets/42525959/a2b60c72-1217-4630-b36c-f7391a7de071)

4.5 - Teste usando a configuração do WildCard no Pi-Hole:
> Mérito do Ricardo Fuhrman, site: https://blog.ricardof.dev/configurando-dominio-wildcard-pihole/
```
root@piholewunbound:/# dig test.jager.net @127.0.0.1 
```
![image](https://github.com/zecaoliveira/dns-in-docker-swarm/assets/42525959/e6f7a79a-1996-411c-80ec-b3abeb7d46cd)

5 - Teste de resolução de nomes para a Internet usando os 3 nós a partir da rede externa:

- Node 01:

![image](https://github.com/zecaoliveira/dns-in-docker-swarm/assets/42525959/9fda0e63-9b87-4d2a-985f-9fd015be8d01)

- Node 02:

![image](https://github.com/zecaoliveira/dns-in-docker-swarm/assets/42525959/1fbc9e11-3a0f-4b86-90e2-a8ca7967160d)

- Node 03:

![image](https://github.com/zecaoliveira/dns-in-docker-swarm/assets/42525959/273c2353-ab9b-499e-81cb-9449f3c50b9c)


## Breve descrição dos recursos usados aqui:

### Overlay network driver

O driver de rede overlay cria uma rede distribuída entre vários hosts do Docker. 

IMPORTANTE: Essa rede fica sobreposta (overlays) as redes específicas do host, permitindo que os contêineres conectados a ela se comuniquem com segurança quando a criptografia está habilitada. 

O Docker lida de forma transparente com o roteamento de cada pacote de um host daemon Docker para o contêiner de destino correto.

Você pode criar redes "overlay" usando "docker network create", da mesma forma que você pode criar redes do tipo "bridge". 

Serviços ou contêineres podem ser conectados a mais de uma rede ao mesmo tempo. 

Os serviços ou contêineres só podem se comunicar através das redes às quais estão conectados.

Redes do tipo "overlay" costumam ser usadas para criar uma conexão entre serviços em um cluster Swarm usando o atributo "attachable: true", mas você também pode usá-las para conectar contêineres independentes em execução em hosts diferentes. 

Ao usar contêineres autônomos, ainda é necessário usar o modo Swarm para estabelecer uma conexão entre os hosts.

Esta página descreve redes de sobreposição em geral e quando usadas com contêineres independentes. 

Para obter informações sobre sobreposição para serviços Swarm, consulte Gerenciar redes de serviços Swarm: https://docs.docker.com/network/drivers/overlay/

### Volume

Os volumes são o mecanismo preferido para persistir dados gerados e usados ​​por contêineres Docker. 

Embora as montagens de ligação dependam da estrutura de diretórios e do sistema operacional da máquina host, os volumes são totalmente gerenciados pelo Docker. 

Os volumes têm diversas vantagens sobre montagens vinculadas (bind type):

- Os volumes são mais fáceis de fazer backup ou migrar do que montagens vinculadas.
- Você pode gerenciar volumes usando comandos Docker CLI ou a API Docker.
- Os volumes funcionam em contêineres Linux e Windows.
- IMPORTANTE: Os volumes podem ser compartilhados com mais segurança entre vários contêineres.
- Os drivers de volume permitem armazenar volumes em hosts remotos ou provedores de nuvem, criptografar o conteúdo dos volumes ou adicionar outras funcionalidades.
- Novos volumes podem ter seu conteúdo pré-preenchido por um contêiner.
- Os volumes no Docker Desktop têm desempenho muito superior às montagens vinculadas de hosts Mac e Windows.
  
Além disso, os volumes costumam ser uma escolha melhor do que persistir dados na camada gravável de um contêiner, porque um volume não aumenta o tamanho dos contêineres que o utilizam e o conteúdo do volume existe fora do ciclo de vida de um determinado contêiner.

Link: https://docs.docker.com/storage/volumes/

Aqui eu concluo este tutorial!

### Observações importantes:

Este projeto serve como base para implementações customizadas. Adapte-o de acordo com suas necessidades específicas.
Mantenha-se atualizado sobre as melhores práticas de segurança em Docker e redes containerizadas.
Desenvolva suas habilidades em DevOps e conquiste as melhores oportunidades no mercado!

Junte-se à comunidade e vamos construir soluções de rede inovadoras e eficientes juntos!

### Créditos e Referências:

Links:

- https://blog.ricardof.dev/configurando-dominio-wildcard-pihole/
- https://docs.pi-hole.net/guides/dns/unbound/
- https://www.cherryservers.com/blog/docker-build-command
- https://unbound.docs.nlnetlabs.nl/en/latest/
- https://docs.github.com/pt/communities/setting-up-your-project-for-healthy-contributions/adding-a-license-to-a-repository
- https://opensource.guide/pt/legal/#:~:text=Se%20voc%C3%AA%20est%C3%A1%20iniciando%20do,o%20aviso%20de%20direitos%20autorais.
- https://github.com/JamesTurland/JimsGarage/tree/main/Unbound
- https://github.com/JamesTurland/JimsGarage/tree/main/Terraform
- https://docs.docker.com/engine/swarm/
- https://cloud-images.ubuntu.com/noble/current/
- https://github.com/robwithtech/homelab
