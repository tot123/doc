FROM alpine

LABEL ts 

USER root

WORKDIR /home/work

RUN apk add --no-cache build-base git && \
    git clone https://github.com/tot123/html2md.git && \
    git clone https://github.com/curlconverter/curlconverter.git && \
    cd ./html2md && npm install && npm run dev && \