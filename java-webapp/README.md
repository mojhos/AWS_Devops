# Scalable Web Application on AWS

A production-grade Java web application with MySQL database integration, designed for deployment on AWS infrastructure.

## 📋 Project Overview

This is a fully automated, production-grade web application that allows users to:
- View application architecture information
- Submit messages through a web form
- View all submitted messages from the database

## 🏗️ Architecture

- **Frontend**: JSP pages with HTML/CSS
- **Backend**: Java Servlets
- **Database**: MySQL (Amazon RDS compatible)
- **Build Tool**: Maven
- **Server**: Compatible with Tomcat, Jetty, or any Java EE container

## 📁 Project Structure

```
scalable-web-app/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── webapp/
│       │           ├── config/
│       │           │   └── DatabaseConfig.java
│       │           ├── dao/
│       │           │   └── MessageDAO.java
│       │           ├── listener/
│       │           │   └── AppContextListener.java
│       │           ├── model/
│       │           │   └── Message.java
│       │           └── servlet/
│       │               ├── DataServlet.java
│       │               ├── HomeServlet.java
│       │               └── InputServlet.java
│       └── webapp/
│           ├── WEB-INF/
│           │   ├── views/
│           │   │   ├── index.jsp
│           │   │   ├── input.jsp
│           │   │   ├── data.jsp
│           │   │   └── error.jsp
│           │   └── web.xml
│           └── META-INF/
├── pom.xml
└── db-schema.sql
```

## 🚀 Prerequisites

- Java JDK 11 or higher
- Apache Maven 3.6+
- MySQL 8.0+
- Apache Tomcat 9.0+ (or similar servlet container)

## 💾 Database Setup

1. **Install MySQL** (if not already installed)
    Be sure that mysql server is accessible on it's IP address

2. **Run the database schema**:
```bash
mysql -u root -p < db-schema.sql
```

3. **Update database credentials** in `src/main/java/com/webapp/config/DatabaseConfig.java`:
```java
private static final String DB_URL = "jdbc:mysql://mysql_ip:3306/**put-your-db-name-here**?useSSL=false&serverTimezone=UTC";
private static final String DB_USER = "root";
private static final String DB_PASSWORD = "your_password";
```

For AWS RDS, update the DB_URL to your RDS endpoint:
```java
private static final String DB_URL = "jdbc:mysql://your-rds-endpoint.region.rds.amazonaws.com:3306/**put-your-db-name-here**?useSSL=true&serverTimezone=UTC";
```

## 🔨 Building the Project

1. **Clone or download the project**

2. **Navigate to project directory**:
```bash
cd java-webapp
```

3. **Build with Maven**:
```bash
mvn clean package
```

This will create a WAR file in the `target/` directory: `webapp.war`

## 🖥️ Deployment

### Local Tomcat Deployment

1. **Copy WAR file to Tomcat**:
```bash
cp target/webapp.war /path/to/tomcat/webapps/
```

2. **Start Tomcat**:
```bash
cd /path/to/tomcat/bin
./catalina.sh run
```

3. **Access the application**:
```
http://localhost:8080/webapp/
```

### AWS Elastic Beanstalk Deployment

1. **Install AWS CLI and EB CLI**

2. **Initialize Elastic Beanstalk**:
```bash
eb init
```

3. **Create environment**:
```bash
eb create production-env
```

4. **Deploy**:
```bash
eb deploy
```

### AWS EC2 Manual Deployment

1. **Launch EC2 instance** (Amazon Linux 2 or Ubuntu)

2. **Install Java and Tomcat**:
```bash
sudo yum install java-11-openjdk-devel
sudo yum install tomcat
```

3. **Upload and deploy WAR file**:
```bash
scp target/webapp.war ec2-user@your-ec2-ip:/var/lib/tomcat/webapps/
```

4. **Start Tomcat**:
```bash
sudo systemctl start tomcat
```

## 🔧 Configuration

### Database Connection Pool

Modify `DatabaseConfig.java` to configure connection pooling:
```java
private static final int MAX_POOL_SIZE = 10;
```

### Session Timeout

Modify `web.xml` to change session timeout (in minutes):
```xml
<session-timeout>30</session-timeout>
```

## 📊 Application Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Home page with architecture description |
| `/input` | GET | Display input form |
| `/input` | POST | Submit message to database |
| `/data` | GET | View all messages from database |

## 🔒 Security Considerations

1. **Update database credentials** - Never commit passwords to version control
2. **Use environment variables** for sensitive data
3. **Enable SSL/TLS** for production deployments
4. **Configure AWS WAF** for web application firewall protection
5. **Use AWS RDS encryption** at rest and in transit
6. **Implement input validation** and sanitization
7. **Use prepared statements** (already implemented) to prevent SQL injection

## 📦 Dependencies

All dependencies are managed through Maven (`pom.xml`):

- **javax.servlet-api** (4.0.1) - Servlet support
- **mysql-connector-java** (8.0.33) - MySQL database driver
- **jstl** (1.2) - JSP Standard Tag Library
- **gson** (2.10.1) - JSON processing

## 🧪 Testing

To test the application locally:

1. Ensure MySQL is running
2. Create the database using `db-schema.sql`
3. Build the project: `mvn clean package`
4. Deploy to local Tomcat
5. Access `http://localhost:8080/webapp/`
6. Test the input form and data viewing functionality

## 🐛 Troubleshooting

### Database Connection Error
- Check MySQL is running: `sudo systemctl status mysql`
- Verify credentials in `DatabaseConfig.java`
- Ensure database `db-name` exists
- Check firewall rules for port 3306

### ClassNotFoundException for MySQL Driver
- Ensure `mysql-connector-java` is in `pom.xml`
- Run `mvn clean install` to download dependencies
- Check the WAR file includes the MySQL driver JAR

### 404 Error on Servlets
- Verify servlet URL patterns in annotations
- Check web.xml configuration
- Ensure WAR is properly deployed
- Check Tomcat logs: `/path/to/tomcat/logs/catalina.out`

### Application Won't Start
- Check Tomcat logs for errors
- Verify Java version: `java -version`
- Ensure port 8080 is not in use: `netstat -an | grep 8080`

## 📝 AWS RDS Configuration

For Amazon RDS MySQL:

1. Create RDS MySQL instance in AWS Console
2. Configure security group to allow inbound traffic on port 3306
3. Note the endpoint, username, and password
4. Update `DatabaseConfig.java` with RDS endpoint
5. Enable Multi-AZ for high availability
6. Set up read replicas for load balancing

## 🔄 Continuous Integration/Deployment

### Using AWS CodePipeline

1. Store code in AWS CodeCommit, GitHub, or Bitbucket
2. Create CodeBuild project with `buildspec.yml`
3. Set up CodePipeline to automate build and deployment
4. Deploy to Elastic Beanstalk or EC2

### Sample buildspec.yml
```yaml
version: 0.2
phases:
  build:
    commands:
      - mvn clean package
artifacts:
  files:
    - target/webapp.war
```

## 📈 Monitoring and Logging

- **Application Logs**: Check Tomcat logs in `/logs/` directory
- **AWS CloudWatch**: Monitor application metrics and logs
- **Database Monitoring**: Use RDS Performance Insights
- **AWS X-Ray**: Implement distributed tracing

## 🤝 Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## 📄 License

This project is open source and available for educational and commercial use.

## 📧 Support

For issues and questions, please check the troubleshooting section or create an issue in the repository.

---

Built with ☕ Java and ❤️ for AWS scalability
