
FROM debian:buster-slim

RUN apt-get update && apt-get -y upgrade && apt-get -y --no-install-recommends --no-install-suggests install iproute2 wget curl nmap openssl tcpdump iperf3 bash-completion netcat net-tools dnsutils traceroute nginx && rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get -y autoremove

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"

RUN openssl dhparam -out /etc/nginx/dhparam.pem 4096

RUN echo "ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;" > /etc/nginx/snippets/self-signed.conf
RUN echo "ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;" >> /etc/nginx/snippets/self-signed.conf

RUN echo "ssl_protocols TLSv1.2;ssl_prefer_server_ciphers on;ssl_dhparam /etc/nginx/dhparam.pem;ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;ssl_ecdh_curve secp384r1; # Requires nginx >= 1.1.0ssl_session_timeout  10m;ssl_session_cache shared:SSL:10m;ssl_session_tickets off; # Requires nginx >= 1.5.9ssl_stapling on; # Requires nginx >= 1.3.7ssl_stapling_verify on; # Requires nginx => 1.3.7resolver 8.8.8.8 8.8.4.4 valid=300s;resolver_timeout 5s;# Disable strict transport security for now. You can uncomment the following# line if you understand the implications.# add_header Strict-Transport-Security \"max-age=63072000; includeSubDomains; preload\";add_header X-Frame-Options DENY;add_header X-Content-Type-Options nosniff;add_header X-XSS-Protection \"1; mode=block\";" > /etc/nginx/snippets/ssl-params.conf

RUN sed -i 's/# listen 443 ssl default_server;/listen 443 ssl default_server;/g' /etc/nginx/sites-available/default
RUN sed -i 's/# listen \[::\]:443 ssl default_server;/listen \[::\]:443 ssl default_server;/g' /etc/nginx/sites-available/default
RUN sed -i '/server_name _;/a \        ssl_certificate \/etc\/ssl\/certs\/nginx-selfsigned.crt;' /etc/nginx/sites-available/default
RUN sed -i '/ssl_certificate \/etc\/ssl\/certs\/nginx-selfsigned.crt;/a \        ssl_certificate_key \/etc\/ssl\/private\/nginx-selfsigned.key;' /etc/nginx/sites-available/default 

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

EXPOSE 80 443 444
