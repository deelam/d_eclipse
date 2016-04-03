FROM readytalk/nodejs

MAINTAINER deelam

# Usage: docker build -t my/app .
  WORKDIR /app
  ADD package.json /app/
  RUN npm install
  ADD . /app

  CMD []
  ENTRYPOINT ["/nodejs/bin/npm", "start"]

