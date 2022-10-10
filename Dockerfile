FROM alpine:edge

ARG AUUID="35d36f7f-4ea5-4aed-a9c0-d6d400cf7c0c"
ARG CADDYIndexPage="https://github.com/wulabing/3DCEList/archive/master.zip"
ARG ParameterSSENCYPT="chacha20-ietf-poly1305"
ARG PORT=8080

ADD etc/Caddyfile /tmp/Caddyfile
ADD etc/config.json /tmp/config.json
ADD start.sh /start.sh

RUN apk update && \
    apk add --no-cache ca-certificates caddy wget && \
    wget -O v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip && \
    unzip v2ray.zip && \
    chmod +x /v2ray && \
    rm -rf /var/cache/apk/* && \
    rm -f v2ray.zip && \
    mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt && \
    wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/ && \
    cat /tmp/Caddyfile | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile && \
    cat /tmp/config.json | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/config.json

RUN chmod +x /start.sh

CMD /start.sh