# Stage 1: Build the application
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /workspace/app

# Copy the Maven project files and download dependencies
COPY pom.xml .
COPY src src
RUN mvn clean package -DskipTests

# Stage 2: Create the final runtime image
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the built JAR file from the builder stage
COPY --from=builder /workspace/app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
