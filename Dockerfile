FROM pihole/pihole:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install unbound vim -y

RUN tee /etc/dnsmasq.d/02-my-wildcard-dns.conf <<EOF

address=/jager.net/127.0.0.1

EOF

RUN tee /etc/dnsmasq.d/05-pihole-custom-cname.conf <<EOF

cname=example.jager.net,jager.net

EOF

RUN tee /etc/pihole/custom.list <<EOF

10.0.0.10 pve01.jager.net
172.16.0.31 bastion01.jager.net
172.16.0.41 controllerk8s01.jager.net
172.16.0.51 nodek8s01.jager.net
172.16.0.52 nodek8s02.jager.net
172.16.0.222 srvnode03.jager.net
172.16.0.211 srvnode01.jager.net
172.16.0.221 srvnode02.jager.net
192.168.61.1 frw01.jager.net

EOF

RUN tee /etc/unbound/unbound.conf.d/pi-hole.conf <<EOF
server:
    # If no logfile is specified, syslog is used
    # logfile: "/var/log/unbound/unbound.log"
    verbosity: 0

    interface: 127.0.0.1
    port: 5335
    do-ip4: yes
    do-udp: yes
    do-tcp: yes

    domain-insecure: "sabrelado.local"
    verbosity: 1
    statistics-interval: 20
    extended-statistics: yes
    num-threads: 4
    tls-cert-bundle: /etc/ssl/certs/ca-certificates.crt
    # file to read root hints from.
    #root-hints: "/etc/unbound/root.hints"

    # Caso seja necessário fixar o IP de origem:
    #outgoing-interface: x.x.x.x
 
    # Abrir a porta apenas nos endereços loopback (!!segurança!!)
    interface: 127.0.0.1
    interface: ::1
 
    # Permitir todos os IPs pois abrimos a porta apenas para a loopback
    access-control: 127.0.0.1/8 allow
    access-control: ::1 allow
    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
    private-address: fd00::/8
    private-address: fe80::/10
	
    # More outgoing connections
    # Depends on number of cores: 1024/cores - 50 
    
	outgoing-range: 512
    num-queries-per-thread: 128
    
    # More cache memory, rrset=msg*2:

    msg-cache-size: 50m
    rrset-cache-size: 100m

    # Power of 4 close to num-threads: 
	
    msg-cache-slabs: 4
    rrset-cache-slabs: 4
    infra-cache-slabs: 4
    key-cache-slabs: 4
 
    cache-max-ttl: 1200
    infra-host-ttl: 60
    infra-lame-ttl: 60
 
    infra-cache-numhosts: 128
    infra-cache-lame-size: 2k
	
    # Larger socket buffer.  OS may need config.
    so-rcvbuf: 4m
    so-sndbuf: 4m
    # Faster UDP with multithreading (only on Linux).
    so-reuseport: yes 

    do-ip4: yes
    do-ip6: yes
    do-udp: yes
    do-tcp: yes
    do-daemonize: yes
 
    username: "unbound"
    directory: "/etc/unbound"
    chroot: ""
    logfile: "/var/log/unbound.log"
    verbosity:1
    log-queries: yes
    use-syslog: yes
    pidfile: "/run/unbound.pid"
 
    identity: "Unbound-LocalCache"
    version: "1.0"
    hide-identity: yes
    hide-version: yes
    so-rcvbuf: 4m
    so-sndbuf: 4m
    harden-glue: yes
    do-not-query-address: 127.0.0.1/8
    do-not-query-localhost: yes
    module-config: "iterator"
 
    #zone localhost
    local-zone: "localhost." static
    local-data: "localhost. 10800 IN NS localhost."
    local-data: "localhost. 10800 IN SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"
    local-data: "localhost. 10800 IN A 127.0.0.1"
 
    local-zone: "127.in-addr.arpa." static
    local-data: "127.in-addr.arpa. 10800 IN NS localhost."
    local-data: "127.in-addr.arpa. 10800 IN SOA localhost. nobody.invalid. 2 3600 1200 604800 10800"
    local-data: "1.0.0.127.in-addr.arpa. 10800 IN PTR localhost."
 
remote-control:
    control-enable: yes
    control-interface: 127.0.0.1
    control-port: 8953
    control-use-cert: "no"

###########################################################################
# FORWARD ZONE
###########################################################################

#include: /opt/unbound/etc/unbound/forward-records.conf

###########################################################################
# LOCAL ZONE
###########################################################################

# Include file for local-data and local-data-ptr
# include: /opt/unbound/etc/unbound/a-records.conf
# include:  /etc/unbound/unbound.conf.d/a-records.conf
# include: /opt/unbound/etc/unbound/srv-records.conf
# include:  /etc/unbound/unbound.conf.d/srv-records.conf
# include: /etc/unbound/unbound.conf.d/pi-hole.conf

###########################################################################
# WILDCARD INCLUDE
###########################################################################
#include: "/etc/unbound/unbound.conf.d/*.conf"

# Operar 100% em modo forward, informe o ip dos servidores DNSs reais:
forward-zone:
    name: "."
    forward-tls-upstream: yes
    forward-addr: 1.1.1.1@853#cloudflare-dns.com
    forward-addr: 8.8.4.4@853#dns.google
    forward-addr: 208.67.222.222@853#resolver1.opendns.com
    forward-addr: 2606:4700:4700::1111@853#cloudflare-dns.com
    forward-addr: 2001:4860:4860::8844@853#dns.google
    
EOF

RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/unbound
RUN mkdir /etc/s6-overlay/s6-rc.d/unbound
RUN echo oneshot | tee /etc/s6-overlay/s6-rc.d/unbound/type 
RUN tee /etc/s6-overlay/s6-rc.d/unbound/up <<EOF
foreground { echo "starting unbound..." }
/etc/init.d/unbound start
EOF
