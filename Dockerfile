
FROM alpine:latest

RUN apk update && apk add nginx

RUN adduser -D -g 'www' www && mkdir /www /run/nginx && chown -R www:www /var/lib/nginx /www /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
Copy index.html /www/index.html

STOPSIGNAL SIGTERM

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
