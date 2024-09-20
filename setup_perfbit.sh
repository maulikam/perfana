#!/bin/bash

# Function to create microservice structure
create_microservice() {
    local service_name=$1
    mkdir -p $service_name/src/main/java/com/perfbit/$service_name/{config,controller,model,repository,service,dto,exception,util}
    mkdir -p $service_name/src/main/resources/graphql
    mkdir -p $service_name/src/test/java/com/perfbit/$service_name
    touch $service_name/src/main/resources/application.yml
    touch $service_name/build.gradle
    touch $service_name/Dockerfile

    # Create build.gradle for the service
    cat << EOF > $service_name/build.gradle
plugins {
    id 'com.netflix.dgs.codegen'
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'com.netflix.graphql.dgs:graphql-dgs-spring-boot-starter'
    implementation project(':common')

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'com.netflix.graphql.dgs:graphql-dgs-spring-boot-starter-test'
}

dependencyManagement {
    imports {
        mavenBom "com.netflix.graphql.dgs:graphql-dgs-platform-dependencies:\${netflixDgsVersion}"
    }
}

generateJava {
    schemaPaths = ["\${projectDir}/src/main/resources/graphql"]
    packageName = 'com.perfbit.app.$service_name.codegen'
    generateClient = true
}
EOF
}

# Create main project directory
#mkdir perfbit && cd perfbit

# Create microservice directories
services=("api-gateway" "auth-service" "project-management-service" "code-analysis-service" "devops-metrics-service" "team-collaboration-service" "ai-insights-service" "reporting-service")

for service in "${services[@]}"
do
    create_microservice $service
done

# Create common directory structure
mkdir -p common/src/main/java/com/perfbit/common
mkdir -p common/src/test/java/com/perfbit/common
cat << EOF > common/build.gradle
dependencies {
    api 'org.springframework.boot:spring-boot-starter-data-jpa'
    api 'org.springframework.kafka:spring-kafka'
    // Add other common dependencies here
}
EOF

# Create deployment directory structure
mkdir -p deployment/kubernetes deployment/docker-compose
touch deployment/docker-compose.yml

# Create docs directory structure
mkdir -p docs/architecture docs/api
touch docs/README.md

# Initialize Git repository
git init

# Create .gitignore file
cat << EOF > .gitignore
# Gradle
.gradle/
build/

# IntelliJ IDEA
.idea/
*.iml

# Eclipse
.classpath
.project
.settings/

# Logs
*.log

# OS generated files
.DS_Store
Thumbs.db
EOF

# Create root build.gradle
cat << EOF > build.gradle
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.3.4' apply false
    id 'io.spring.dependency-management' version '1.1.6' apply false
    id 'com.netflix.dgs.codegen' version '6.2.1' apply false
    id 'org.graalvm.buildtools.native' version '0.10.3' apply false
}

subprojects {
    apply plugin: 'java'
    apply plugin: 'org.springframework.boot'
    apply plugin: 'io.spring.dependency-management'

    group = 'com.perfbit.app'
    version = '0.0.1-SNAPSHOT'

    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(23)
        }
    }

    repositories {
        mavenCentral()
    }

    dependencies {
        implementation 'org.springframework.boot:spring-boot-starter'
        compileOnly 'org.projectlombok:lombok'
        annotationProcessor 'org.projectlombok:lombok'
        testImplementation 'org.springframework.boot:spring-boot-starter-test'
    }

    test {
        useJUnitPlatform()
    }
}

ext {
    set('netflixDgsVersion', "9.1.2")
}
EOF

# Create settings.gradle
cat << EOF > settings.gradle
rootProject.name = 'perfbit'

include 'api-gateway'
include 'auth-service'
include 'project-management-service'
include 'code-analysis-service'
include 'devops-metrics-service'
include 'team-collaboration-service'
include 'ai-insights-service'
include 'reporting-service'
include 'common'
EOF

echo "Perfbit project structure has been set up successfully!"
echo "Next steps:"
echo "1. Review and customize the generated build.gradle files for each service."
echo "2. Add necessary dependencies and configurations to each service."
echo "3. Implement your microservices using Spring Boot and Netflix DGS."
echo "4. Use 'gradle build' to build your project."