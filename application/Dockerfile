# Use a base image optimized for ARM64 architecture
FROM maven:3.9.6-eclipse-temurin-11

# Set the working directory inside the container
WORKDIR /app

# Copy your Spring Boot application's source code (pom.xml and src) into the container
COPY pom.xml .
COPY src src
COPY .env .env
# Install Maven

# Build your Spring Boot application using Maven
RUN mvn package -Dmaven.test.skip=true
# Expose the port your Spring Boot application runs on (typically 8080)
EXPOSE 8080

# Copy the built JAR file into the container
COPY target/app-0.0.1-RC.jar app.jar

# Define the entry point command to run your Spring Boot application
CMD ["java", "-jar", "app.jar"]
