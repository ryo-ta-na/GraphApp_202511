# Build stage
FROM node:18 AS builder
# ARG REACT_APP_API_BASE
# ENV REACT_APP_API_BASE=$REACT_APP_API_BASE
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for nginx
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]