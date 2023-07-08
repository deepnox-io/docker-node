FROM node:18.16.1-alpine3.18 as builder

ENV CONSISTENCY_ENTRYPOINTS__BRANCH="dev" \
    CONSISTENCY_SCRIPTS__BRANCH="dev" 

ENV CONSISTENCY_ENTRYPOINTS__BASE_URL="https://raw.githubusercontent.com/deepnox-io/consistency-entrypoints/${CONSISTENCY_ENTRYPOINTS__BRANCH}" \
    CONSISTENCY_SCRIPTS__BASE_URL="https://raw.githubusercontent.com/deepnox-io/consistency-scripts/${CONSISTENCY_ENTRYPOINTS__BRANCH}"


RUN apk add --update bash curl openssl libstdc++ proj-util python3-dev py3-pip \ 
    && echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories \
    && apk add -U shadow \
    && pip3 install pip --no-cache-dir --upgrade pip \
                                                 cython \
                                                 setuptools \
                                                 supervisor \
    && mkdir -p /app \
    && chown -R node.node /app \
    && usermod -d /app node \
    && curl -o /opt/entrypoint.sh "${CONSISTENCY_SCRIPTS__BASE_URL}/src/core.module.bash" \
    && curl -o /opt/entrypoint.sh "${CONSISTENCY_SCRIPTS__BASE_URL}/src/download.module.bash" \
    && curl -o /opt/entrypoint.sh "${CONSISTENCY_ENTRYPOINTS__BASE_URL}/src/generic-entrypoint.sh" \
    && chmod +x /opt/*.sh \
    && rm -rf .build-deps \
              /tmp/* \
              /var/cache/apk/*

FROM scratch

COPY --from=builder ["/", "/"]

USER node
WORKDIR "/app"

ENTRYPOINT ["/opt/entrypoint.sh"]

CMD ["node"]
