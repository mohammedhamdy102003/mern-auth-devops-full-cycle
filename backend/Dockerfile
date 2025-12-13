# Dockerfile
FROM node:20-alpine

WORKDIR /app

# نسخ ملفات package.json و package-lock.json
COPY package*.json ./

# تثبيت الاعتماديات
RUN npm install 

# نسخ باقي الكود
COPY . .

EXPOSE 5000

CMD ["npm", "start"]

