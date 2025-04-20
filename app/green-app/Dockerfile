FROM node:18-alpine
WORKDIR /usr/src/app
COPY package.json . 
RUN npm install --production
COPY . .
CMD ["npm", "start"]
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl --fail http://localhost:3000/health || exit 1
