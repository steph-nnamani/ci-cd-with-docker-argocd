# You can change this base image to anything else
# But make sure to use the correct version of Java
FROM adoptopenjdk/openjdk11:alpine-jre

# Simply the artifact path
ARG artifact=target/teslaweb.war

WORKDIR /opt/app

COPY ${artifact} app.war

# This should not be changed
ENTRYPOINT ["java","-jar","app.war"]
