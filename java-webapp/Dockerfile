# Stage 1: Create the final image with a web server
FROM tomcat:9.0-jdk17
LABEL maintainer="Mojtaba Hosseini <s,mojtaba.h65@gmail.com>"

# Remove the default webapps (like the example web app)
RUN rm -rf /usr/local/tomcat/webapps/examples \
    && rm -rf /usr/local/tomcat/webapps/docs \
    && rm -rf /usr/local/tomcat/webapps/host-manager \
    && rm -rf /usr/local/tomcat/webapps/manager \
    && rm -rf /usr/local/tomcat/webapps/ROOT

# Copy the WAR package into the webapps folder.
# The WAR file will be automatically deployed when the container starts.
COPY target/webapp.war /usr/local/tomcat/webapps/ROOT.war

# Expose the default Tomcat port
EXPOSE 8080

# This is the default command for the Tomcat image, explicitly included for clarity.
# It starts the server in the foreground.
CMD ["catalina.sh", "run"]

