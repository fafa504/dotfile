#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}Checking environment...${NC}"

# Check Java
if ! command -v java >/dev/null 2>&1; then
    echo -e "${RED}Java not found. Please install JDK 17 or higher.${NC}"
    exit 1
fi

# Check Maven
if ! command -v mvn >/dev/null 2>&1; then
    echo -e "${RED}Maven not found. Please install Maven.${NC}"
    exit 1
fi

# Check Docker
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}Docker not found. Please install Docker.${NC}"
    exit 1
fi

echo -e "${GREEN}Java:${NC} $(java -version 2>&1 | head -n 1)"
echo -e "${GREEN}Maven:${NC} $(mvn -v | head -n 1)"
echo -e "${GREEN}Docker:${NC} $(docker -v)"

if [ -d "/usr/lib/jvm/java-25-openjdk" ]; then
    export JAVA_HOME=/usr/lib/jvm/java-25-openjdk
elif [ -d "/usr/lib/jvm/java-17-openjdk" ]; then
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
elif [ -n "$JAVA_HOME" ]; then
    echo -e "${YELLOW}Using existing JAVA_HOME: $JAVA_HOME${NC}"
else
    echo -e "${RED}Could not auto-detect JDK. Please set JAVA_HOME manually or adjust script.${NC}"
    exit 1
fi
export PATH=$JAVA_HOME/bin:$PATH
echo -e "${BLUE}JAVA_HOME set to:${NC} $JAVA_HOME"

TOMCAT_VERSION="10-jdk17"

read -p "Nhập tên project (PROJECT_NAME): " PROJECT_NAME
read -p "Nhập tên package (com.example): " PACKAGE_NAME
read -p "Nhập tên servlet (SERVLET_NAME): " SERVLET_NAME

echo -e "${CYAN}Creating project structure...${NC}"
mkdir -p $PROJECT_NAME/src/main/java/$(echo $PACKAGE_NAME | tr '.' '/') \
    $PROJECT_NAME/src/main/webapp/WEB-INF

cd $PROJECT_NAME

echo -e "${CYAN}Generating source files...${NC}"

cat >src/main/java/$(echo $PACKAGE_NAME | tr '.' '/')/${SERVLET_NAME}.java <<EOF
package $PACKAGE_NAME;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class $SERVLET_NAME extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<html><body>");
        out.println("<h2>Hello from $SERVLET_NAME!</h2>");
        out.println("<p>Project: $PROJECT_NAME</p>");
        out.println("</body></html>");
    }
}
EOF

# web.xml
cat >src/main/webapp/WEB-INF/web.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee
                             https://jakarta.ee/xml/ns/jakartaee/web-app_5_0.xsd"
         version="5.0">
    <servlet>
        <servlet-name>$SERVLET_NAME</servlet-name>
        <servlet-class>$PACKAGE_NAME.$SERVLET_NAME</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>$SERVLET_NAME</servlet-name>
        <url-pattern>/hello</url-pattern>
    </servlet-mapping>
</web-app>
EOF

cat >pom.xml <<EOF
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>$PACKAGE_NAME</groupId>
    <artifactId>$PROJECT_NAME</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>jakarta.servlet</groupId>
            <artifactId>jakarta.servlet-api</artifactId>
            <version>6.0.0</version>
            <scope>provided</scope>
        </dependency>
    </dependencies>

    <build>
        <finalName>$PROJECT_NAME</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.3.2</version>
            </plugin>
        </plugins>
    </build>
</project>
EOF

echo -e "${CYAN}Building project with Maven...${NC}"
if mvn clean package; then
    echo -e "${GREEN}Maven build successful.${NC}"
else
    echo -e "${RED}Maven build failed.${NC}"
    exit 1
fi

if [ ! -f "target/${PROJECT_NAME}.war" ]; then
    echo -e "${RED}WAR file not found: target/${PROJECT_NAME}.war${NC}"
    exit 1
fi

cat >Dockerfile <<EOF
FROM tomcat:$TOMCAT_VERSION
COPY target/${PROJECT_NAME}.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]
EOF

echo -e "${CYAN}Building Docker image...${NC}"
docker build -t ${PROJECT_NAME}-image .

if docker ps -a | grep -q "${PROJECT_NAME}-container"; then
    echo -e "${YELLOW}Removing old container...${NC}"
    docker rm -f ${PROJECT_NAME}-container || true
fi

echo -e "${CYAN}Running new Tomcat container...${NC}"
docker run -d --name ${PROJECT_NAME}-container -p 8080:8080 ${PROJECT_NAME}-image

echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${BLUE}Access your app at:${NC} http://localhost:8080/${PROJECT_NAME}/hello"

echo -e "${CYAN}Generating rebuild script (build.sh)...${NC}"

cat >build.sh <<EOF
#!/bin/bash
set -e

# --- Variables embedded from generator ---
PROJECT_NAME="${PROJECT_NAME}"
# -----------------------------------------

# Define image and container names based on the project name
IMAGE_NAME="${PROJECT_NAME}-image"
CONTAINER_NAME="${PROJECT_NAME}-container"

echo "=============================="
echo " REBUILD AND REDEPLOY SCRIPT"
echo " Project: $PROJECT_NAME"
echo "=============================="

echo "[1/4] Building WAR file..."
if ! mvn clean package; then
    echo "Maven build failed."
    exit 1
fi

echo "[2/4] Building Docker image..."
docker build -t $IMAGE_NAME .

if docker ps -a | grep -q "$CONTAINER_NAME"; then
    echo "[3/4] Removing old container..."
    docker rm -f $CONTAINER_NAME
fi

echo "[4/4]Running new container..."
docker run -d --name $CONTAINER_NAME -p 8080:8080 $IMAGE_NAME

echo "==================================="
echo " Deployment complete."
echo " Access at: http://localhost:8080/${PROJECT_NAME}/hello"
echo "==================================="
EOF

chmod +x build.sh

echo -e "${GREEN}All done! Run './build.sh' inside the '$PROJECT_NAME' directory to rebuild.${NC}"
