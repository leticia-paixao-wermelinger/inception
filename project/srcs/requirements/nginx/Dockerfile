FROM alpine:3.21

RUN apk update && apk upgrade && apk add --no-cache nginx

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]