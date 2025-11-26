# Stage 1 — Build the JAR
FROM maven:3.9.4-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2 — Runtime image (ARM64 compatible)
FROM eclipse-temurin:17-jre

WORKDIR /app

# Copy the EXACT jar from the builder stage
# This avoids wildcard issues
COPY --from=builder /app/target/*-SNAPSHOT.jar app.jar

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
