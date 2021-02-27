
FROM alpine:latest

RUN apk update && apk add nginx iproute2 wget curl nmap tcpdump iperf3 iperf bind-tools mtr fping sed tcptraceroute iputils

RUN adduser -D -g 'www' www && mkdir /www /run/nginx && chown -R www:www /var/lib/nginx /www /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /www/index.html

STOPSIGNAL SIGTERM

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
