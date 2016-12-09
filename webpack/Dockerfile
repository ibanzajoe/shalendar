FROM node:6.2.0

WORKDIR /webpack
EXPOSE 8080
CMD npm run dev

RUN npm install -g webpack

ADD package.json /tmp/package.json
RUN cd /tmp && npm install

ADD ./ /webpack
RUN cp -R /tmp/node_modules /webpack

VOLUME ["/webpack/node_modules"]