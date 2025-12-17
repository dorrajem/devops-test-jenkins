# Build stage
FROM maven:3.9.5-eclipse-temurin-17 AS build
WORKDIR /app

# Copier les fichiers de configuration Maven
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copier le code source et builder
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Créer un utilisateur non-root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copier le JAR depuis le build stage
COPY --from=build /app/target/*.jar app.jar

# Exposer le port Spring Boot
EXPOSE 8080

# Variables d'environnement
ENV JAVA_OPTS="-Xms256m -Xmx512m"

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Lancer l'application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]