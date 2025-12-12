
FROM openjdk:17-jdk-slim


WORKDIR /app

COPY . .

COPY pom.xml ./                      

RUN mvn clean package


EXPOSE 8080


 CMD ["java", "-jar", "target/app.jar"]  
