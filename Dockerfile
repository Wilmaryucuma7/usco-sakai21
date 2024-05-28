FROM maven:3.6.0-jdk-8 as build

# Work around a bug in Java 1.8u181 / the Maven Surefire plugin.
# See https://stackoverflow.com/questions/53010200 and
# https://issues.apache.org/jira/browse/SUREFIRE-1588.
ENV JAVA_TOOL_OPTIONS "-Djdk.net.URLClassPath.disableClassPathURLCheck=true"

# Build Sakai.
COPY sakai sakai
WORKDIR sakai

# nb. Skip tests to speed up the container build.
RUN mvn install -Dmaven.test.skip=true -DskipTests

# Download and install Apache Tomcat.
RUN mkdir -p /opt/tomcat
RUN curl "https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.35/bin/apache-tomcat-8.5.35.tar.gz" > /opt/tomcat/tomcat.tar.gz
RUN tar -C /opt/tomcat -xf /opt/tomcat/tomcat.tar.gz --strip-components 1

# Configure Tomcat.
# See https://confluence.sakaiproject.org/display/BOOT/Install+Tomcat+8
ENV CATALINA_HOME /opt/tomcat
COPY context.xml /opt/tomcat/conf/

# Install web app.
RUN mvn sakai:deploy -Dmaven.tomcat.home=/opt/tomcat

FROM openjdk:8

# Copy Sakai configuration.
COPY sakai.properties /opt/tomcat/sakai/

# Copy Sakai and Tomcat.
COPY --from=build /opt/tomcat /opt/tomcat

# Run Sakai
EXPOSE 8080
WORKDIR /opt/tomcat/bin
CMD ./startup.sh && tail -f ../logs/catalina.out

# Primera etapa: Construir dependencias de Maven
# FROM maven:3.8.4-jdk-8 as maven_builder

# # Copiar solo el archivo POM para descargar dependencias
# COPY sakai21/pom.xml /usr/src/app/

# # Directorio de trabajo
# WORKDIR /usr/src/app

# # Descargar dependencias de Maven
# RUN mvn dependency:go-offline

# # Segunda etapa: Construir y empaquetar la aplicación Sakai
# FROM maven:3.8.4-jdk-8 as build

# ENV JAVA_TOOL_OPTIONS "-Djdk.net.URLClassPath.disableClassPathURLCheck=true"

# COPY settings.xml /root/.m2/settings.xml

# # Copiar todo el código fuente
# COPY sakai21 /usr/src/app

# # Directorio de trabajo
# WORKDIR /usr/src/app

# # Construir la aplicación Sakai
# # RUN mvn install -Dmaven.test.skip=true -DskipTests
# RUN mvn clean install -U -Dmaven.test.skip=true -DskipTests
# # Download and install Apache Tomcat.
# RUN mkdir -p /opt/tomcat
# RUN curl "https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.35/bin/apache-tomcat-8.5.35.tar.gz" > /opt/tomcat/tomcat.tar.gz
# RUN tar -C /opt/tomcat -xf /opt/tomcat/tomcat.tar.gz --strip-components 1

# # Configure Tomcat.
# # See https://confluence.sakaiproject.org/display/BOOT/Install+Tomcat+8
# ENV CATALINA_HOME /opt/tomcat
# COPY context.xml /opt/tomcat/conf/
# # COPY server.xml /opt/tomcat/conf/

# # Install web app.
# RUN mvn sakai:deploy -Dmaven.tomcat.home=/opt/tomcat

# FROM openjdk:8

# # Copy Sakai configuration.
# COPY sakai.properties /opt/tomcat/sakai/

# # Copy Sakai and Tomcat.
# COPY --from=build /opt/tomcat /opt/tomcat

# # Run Sakai
# EXPOSE 8080
# WORKDIR /opt/tomcat/bin
# CMD ./startup.sh && tail -f ../logs/catalina.out

