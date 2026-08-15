# Stage 1: Build the Fat JAR inside Docker
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /build

# Copy the entire workspace into the builder image
COPY . .

# --- TEMP DEBUG: confirm the source actually made it into the build context ---
RUN echo "=== Top-level context ===" && ls -la /build
RUN echo "=== Looking for source files ===" && find /build -name "*.java" -not -path "*/build/*"
RUN echo "=== settings.gradle (if any) ===" && (cat settings.gradle || echo "no settings.gradle found")
# --------------------------------------------------------------------------

# Make sure the Gradle wrapper is executable regardless of the host's file mode
RUN chmod +x ./gradlew

# Compile and package the Fat JAR inside the isolated container
RUN ./gradlew clean build -x test --stacktrace

# --- TEMP DEBUG: show everything gradle actually produced ---
RUN echo "=== Contents of /build/build after gradle run ===" && find /build/build -maxdepth 4
# --------------------------------------------------------------------------

# Stage 2: Clean, tiny production runtime
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

COPY --from=builder /build/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
