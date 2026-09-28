# se_lab_cicd

A CLI calculator built in Java/Maven, used as the sample application for a Software
Engineering lab exercise on CI/CD: build, test, containerize, and publish with Jenkins
and Docker.

## What's here

- `src/main/java/com/calculator/Calculator.java` — `add`, `subtract`, `multiply`,
  `divide` (double-precision; `divide` throws `IllegalArgumentException` on a zero
  divisor), plus a `parseNumber` helper for parsing CLI arguments.
- `src/main/java/com/calculator/Main.java` — CLI entry point. Takes an operation name
  and two numbers as arguments (`add`/`subtract`/`multiply`/`divide`), prints the
  result, and prints usage help on invalid input.
- `src/test/java/com/calculator/CalculatorTest.java` — unit tests for `Calculator`.
- `pom.xml` — Maven build configuration.
- `Dockerfile` — multi-stage build: compiles with `maven:3.9.4-eclipse-temurin-17`,
  then runs the packaged jar on a slim `eclipse-temurin:17-jre` image as a non-root
  user.
- `Jenkinsfile` — pipeline stages: checkout → build (`mvn clean compile`) → test
  (`mvn test`, with archived surefire reports) → package (`mvn package -DskipTests`)
  → build Docker image (`mattjoe/calculator:latest`) → push to Docker Hub, with
  workspace cleanup on completion.
- `target/` — committed Maven build output (compiled classes, surefire reports); this
  is normally generated, not hand-written.

## Running it

```bash
mvn clean compile
mvn test
mvn package -DskipTests
java -jar target/*.jar add 2 3
```

Or with Docker:

```bash
docker build -t calculator .
docker run calculator add 2 3
```

The `Jenkinsfile` runs the same steps end-to-end and additionally builds/pushes the
Docker image (requires Docker Hub credentials configured in Jenkins).

## Tech stack

Java, Maven, JUnit, Docker, Jenkins.
