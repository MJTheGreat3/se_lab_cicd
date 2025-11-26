# Multi-stage build for Simple Calculator CLI Application
FROM maven:3.9.4-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml first for better layer caching
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests


# ===== RUNTIME STAGE (M1/M2 Mac compatible) =====
FROM eclipse-temurin:17-jre

WORKDIR /app

# Copy JAR from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Create non-root user
RUN addgroup --gid 1000 appgroup && \
    adduser --uid 1000 --ingroup appgroup --disabled-password appuser

USER appuser

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

CMD []
