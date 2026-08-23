FROM node:22

WORKDIR /app

COPY backend/package*.json ./

RUN npm install

COPY backend/src ./src

EXPOSE 3000

CMD ["npm", "run", "dev"]