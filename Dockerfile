# Use eclipse-temurin Java 21 to match your build.gradle toolchain
FROM eclipse-temurin:21-jre-alpine

# Set working directory inside the container
WORKDIR /app

# Copy the app.jar compiled by your Gradle build
COPY build/libs/app.jar app.jar

# Run the application using the main class path defined in your build configuration
ENTRYPOINT ["java", "-jar", "app.jar"]
