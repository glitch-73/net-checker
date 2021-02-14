
FROM alpine:latest

RUN apk update && apk add nginx

RUN set -x \
    && addgroup -g 101 -S nginx && adduser -g 101 -h /home/nginx -s /sbin/nologin -G nginx -g nginx nginx

STOPSIGNAL SIGTERM

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
