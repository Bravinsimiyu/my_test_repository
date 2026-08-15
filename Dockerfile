# Stage 1: Build the Fat JAR inside Docker
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /build

# Copy the entire workspace into the builder image
COPY . .

# FIXED: This line must be here to grant Linux execution permissions
RUN chmod +x gradlew

# Compile and package the Fat JAR inside the isolated container
RUN ./gradlew clean build -x test

# Stage 2: Clean, tiny production runtime
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Safely copy the JAR produced during Stage 1
COPY --from=builder /build/build/libs/app.jar app.jar

# Execute the application asset
ENTRYPOINT ["java", "-jar", "app.jar"]
