# syntax=docker/dockerfile:1
# --- Build stage ---
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml ./
RUN --mount=type=cache,target=/root/.m2 mvn -q -B dependency:go-offline
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -q -B clean package -DskipTests

# --- Runtime stage ---
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
# Fixed UID/GID so the Kubernetes securityContext (runAsUser/fsGroup) can match it.
RUN addgroup -S -g 10001 appgroup && adduser -S -u 10001 -G appgroup appuser
COPY --from=build /app/target/*.jar app.jar
RUN mkdir -p /app/generated-media && chown -R appuser:appgroup /app
USER 10001:10001
ENV MEDIA_STORAGE_DIR=/app/generated-media \
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=70 -XX:+UseSerialGC -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir=/tmp"
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
