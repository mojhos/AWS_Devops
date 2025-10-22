

# 🌐 Java Web Application — Setup Guide

This guide walks you through **three simple ways** to run and deploy this Java web application:

1. 🐳 Using **Docker Compose** (recommended — easiest and fastest)
2. ⚙️ Installing **manually** (for educational or debugging purposes)
3. 🤖 Automating everything using **Jenkins CI/CD** + **AWS ECR**

---

## 🧭 Overview

This project is a simple **Java Servlet + JSP web application** connected to a **MySQL database**, packaged with **Maven**, and deployable with **Docker** or **Jenkins**.

You can:

* Run the app locally with one command using Docker Compose
* Install manually on any Linux server with MySQL and Tomcat
* Automate packaging and deployment using Jenkins pipelines

---

## 📂 Project Structure

```
java-webapp/
├── src/                        # Java servlet source code
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
├── pom.xml                     # Maven build configuration
├── db-schema.sql               # Database schema & sample data
├── Dockerfile                  # Docker image definition
├── docker-compose.yaml         # Multi-container setup (app + MySQL)
├── Jenkinsfile                 # Jenkins pipeline script
├── groovy.script               # Functions to use in jenkins file
└── README.md                   # You're reading it :)
```

---

## 🧱 Requirements

To use any of the following methods, make sure you have:

* **Java 11+**
* **Maven 3.6+**
* **Docker & Docker Compose**
* **Git** (optional for Jenkins)
* **MySQL or Dockerized MySQL**

---

# 🐳 1️⃣ Run Application with Docker Compose (Recommended)

This is the simplest and fastest way to get your app running.

### 🧩 Steps

1. **Build the Java package**

   ```bash
   mvn clean package
   ```

2. **Build the Docker image locally**

   ```bash
   docker build -t webapp:1.0 .
   ```

3. **Run the app with Docker Compose**

   ```bash
   docker-compose up -d
   ```

4. **Access your application**

   * Web App: [http://localhost:8080](http://localhost:8080)
   * MySQL: available on `localhost:3306`
     (user: `webapp_user`, password: `password`)

5. **Stop everything**

   ```bash
   docker-compose down
   ```

---

# ⚙️ 2️⃣ Manual Installation (Without Docker)

This section shows how to manually install and run the app on any Linux server (e.g., Ubuntu).

---

## 🧩 Step 1: Install MySQL Server

Run the following commands to install and configure MySQL:

```bash
sudo apt update
sudo apt install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
```

Then secure your MySQL installation:

```bash
sudo mysql_secure_installation
```

---

### 🧩 Step 2: Create a Database and Import the Schema

Log in to MySQL and import the schema file to create database and user:

```bash
sudo mysql -u root -p < db-schema.sql
```
    Be sure that mysql server is accessible on it's IP address( check the /etc/mysql/mysql.conf.d/mysqld.cnf ==> "bind-address = 0.0.0.0" )


## 🧩 Step 3: Install Apache Tomcat 9

Run these commands to install Tomcat 9:

```bash
sudo apt install -y wget
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.90/bin/apache-tomcat-9.0.90.tar.gz
sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-9.0.90.tar.gz -C /opt/tomcat --strip-components=1
sudo chmod +x /opt/tomcat/bin/*.sh
```

Start Tomcat:

```bash
cd /opt/tomcat/bin
sudo ./startup.sh
```

---

## 🧩 Step 4: Deploy the Application

1. First, build your `.war` package using Maven:

   ```bash
   mvn clean package
   ```

2. Copy the generated WAR file to Tomcat’s webapps directory:

   ```bash
   sudo cp target/webapp.war /opt/tomcat/webapps/
   ```

3. Restart Tomcat:

   ```bash
   sudo ./shutdown.sh
   sudo ./startup.sh
   ```

4. Open your browser and visit:

   ```
   http://<your-server-ip>:8080/webapp
   ```

---

# 🤖 3️⃣ Automated Deployment with Jenkins CI/CD

You can automate **building**, **Dockerizing**, and **pushing** your app to **AWS ECR** using Jenkins.

---

## 🧩 Step 1: Install Jenkins

For Ubuntu:

```bash
sudo apt update
sudo apt install -y openjdk-11-jdk
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

Then open Jenkins at [http://localhost:8080](http://localhost:8080)
and complete the setup wizard.

---

## 🧩 Step 2: Configure Jenkins Environment

Install these tools on the Jenkins server:

```bash
sudo apt install -y docker.io awscli git
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

Ensure your Jenkins server has AWS credentials configured:

```bash
sudo su - jenkins
aws configure
```

---

## 🧩 Step 3: Create a Pipeline

1. In Jenkins, click **New Item → Pipeline**
2. Connect your pipeline to your **Git repository**
3. Select **“Pipeline script from SCM”**
4. Choose **Git**, and enter your repo URL
5. Jenkins will use the `Jenkinsfile` and `script.groovy` from your project

---

## 🧩 Step 4: What the Jenkins Pipeline Does

Once triggered (automatically or manually), it will:

1. Pull the latest code from GitHub
2. Run `mvn clean package` to create the WAR file
3. Build a Docker image from your Dockerfile
4. Push the Docker image to your **AWS ECR** repository
5. Optionally trigger Terraform or EC2 update to redeploy the new version

---

## 🧩 Step 5: Automate on Code Push

You can connect Jenkins with your Git account to automatically run the pipeline when new commits are pushed to your **main branch**.

* Go to your Git repo settings → Webhooks
* Add Jenkins webhook URL:

  ```
  http://<your-jenkins-server>:8080/github-webhook/
  ```
* Choose event: “Just the push event”
* Save

Now, each code push triggers the pipeline to build and deploy a new Docker image automatically 🚀

---

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

---

# ✅ Summary

| Deployment Method  | Description                           | Best For                 |
| ------------------ | ------------------------------------- | ------------------------ |
| **Docker Compose** | Quick local setup (includes MySQL)    | Beginners, local testing |
| **Manual Setup**   | Classic install (MySQL + Tomcat)      | Servers without Docker   |
| **Jenkins CI/CD**  | Full automation (build, push, deploy) | Production / AWS users   |

---

## 🧾 License

This project is open source and free to use under the MIT License.

---

## ❤️ Thank you for your attention

Built with ☕ **Java**, 🐳 **Docker**, 🤖 **Jenkins**, and ☁️ **AWS**

