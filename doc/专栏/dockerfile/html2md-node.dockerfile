FROM node:20-alpine3.18
RUN apk add --no-cache git && \
    git clone https://github.com/tot123/html2md.git 
    # git clone https://github.com/curlconverter/curlconverter.git && \
RUN     cd ./html2md && npm install 

EXPOSE 8080
ENTRYPOINT ["/bin/sh", "-c", "npm run dev"]









