# Stage 1: Build the Fat JAR inside Docker
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /build

# Copy the entire workspace into the builder image
COPY . .

# Make sure the Gradle wrapper is executable regardless of the host's file mode
RUN chmod +x ./gradlew

# Compile and package the Fat JAR inside the isolated container
# --stacktrace + --info surface the real failure instead of it being swallowed
RUN ./gradlew clean build -x test --stacktrace

# Debug step: confirm what actually landed in build/libs.
# Remove this line once the build is passing reliably.
RUN ls -la /build/build/libs/

# Stage 2: Clean, tiny production runtime
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Wildcard is more forgiving than a hardcoded filename if the archive
# name ever changes (version suffix, plugin defaults, etc.)
COPY --from=builder /build/build/libs/*.jar app.jar

# Execute the application asset
ENTRYPOINT ["java", "-jar", "app.jar"]
