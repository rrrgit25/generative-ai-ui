# syntax=docker/dockerfile:1
# React SPA served by unprivileged nginx (used when CloudFront/S3 hosting is disabled).
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --no-audit --no-fund
COPY public ./public
COPY src ./src
# Empty base URL = same origin: Traefik routes /api and /media to the backend.
ENV REACT_APP_API_BASE_URL="" CI=true GENERATE_SOURCEMAP=false
RUN npm run build

FROM nginxinc/nginx-unprivileged:1.30-alpine
# Pick up Alpine security fixes released after the base image was built.
USER root
RUN apk upgrade --no-cache
COPY deploy/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html
USER 101
EXPOSE 8080
