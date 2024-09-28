## I. Create `Spring Boot Project` with Maven
### 1. create project:
```powershell
# command
mvn archetype:generate -DgroupId=com.duongdx -DartifactId=spring-boot-project -DarchetypeArtifactId=maven-archetype-webapp -DarchetypeVersion=1.5 -DinteractiveMode=false

# result:
> tree -L 1 ./
./
├── spring-boot-project
├── vprofile-project
└── worker.pem

```

## II. Maven for Devops
### 1. Maven `.m2` folder:
```t
The .m2 folder is the default location where Maven stores its local repository(downloaded dependencies).
It contains settings.xml file which includes Maven configurations like repository locations, proxy settings etc.

It is a hidden folder, if not able to access it then you may need to enable the display of hidden files and folders in your file explorer.

The locations depends on the OS.
If Windows- C:\Users\{username}\.m2
Mac- /Users/{username}/.m2
Linux- /home/{username}/.m2
```
### 2. Maven Default Lifecycle

| **Phase**               | **Description**                                                                 |
|-------------------------|---------------------------------------------------------------------------------|
| **validate**            | Validate the project is correct and all necessary information is available.     |
| **initialize**          | Initialize build state, e.g. set properties or create directories.              |
| **generate-sources**    | Generate any source code for inclusion in compilation.                          |
| **process-sources**     | Process the source code, for example to filter any values.                      |
| **generate-resources**  | Generate resources for inclusion in the package.                                |
| **process-resources**   | Copy and process the resources into the destination directory, ready for packaging. |
| **compile**             | Compile the source code of the project.                                          |
| **process-classes**     | Post-process the generated files from compilation, for example to do bytecode enhancement on Java classes. |
| **generate-test-sources** | Generate any test source code for inclusion in compilation.                    |
| **process-test-sources** | Process the test source code, for example to filter any values.                 |
| **generate-test-resources** | Create resources for testing.                                                |
| **process-test-resources** | Copy and process the resources into the test destination directory.           |
| **test-compile**        | Compile the test source code into the test destination directory.                |
| **process-test-classes** | Post-process the generated files from test compilation, for example to do bytecode enhancement on Java classes. |
| **test**                | Run tests using a suitable unit testing framework. These tests should not require the code be packaged or deployed. |
| **prepare-package**     | Perform any operations necessary to prepare a package before the actual packaging. This often results in an unpacked, processed version of the package. |
| **package**             | Take the compiled code and package it in its distributable format, such as a JAR. |
| **pre-integration-test** | Perform actions required before integration tests are executed. This may involve things such as setting up the required environment. |
| **integration-test**    | Process and deploy the package if necessary into an environment where integration tests can be run. |
| **post-integration-test** | Perform actions required after integration tests have been executed. This may include cleaning up the environment. |
| **verify**              | Run any checks to verify the package is valid and meets quality criteria.        |
| **install**             | Install the package into the local repository, for use as a dependency in other projects locally. |
| **deploy**              | Done in an integration or release environment, copies the final package to the remote repository for sharing with other developers and projects. |

### 3. `maven` goal:
```t
1. `validate`: Checks if the project is correct and all necessary information is `available`.
2. `compile`: Compiles the source code of the project.
3. `test-compile`: Compiles the test source code.
4. `test`: Runs the unit tests using a testing framework (JUnit, TestNG, etc.).
5. `package`: Packages the compiled code into a JAR, WAR, etc.
6. `integration-test`: Processes and deploys the package if necessary to run integration tests.
7. `verify`: Runs checks to ensure the package is valid and meets quality standards.
8. `install`: Installs the package into the local Maven repository. maven save artifact to `~/.m2/repository`
9. `deploy`: Copies the final package to the remote repository for sharing with other developers or projects.
```

### 4. `maven test` goal:
```t
-  `validate`
-  `compile`
-  `test-compile`
-  `test` (Runs unit tests)
```

### 5. `maven verify` goal:
```t
- `validate`
-  `compile`
-  `test-compile`
-  `test` (Runs unit tests)
-  `package` (Packages the code)
-  `integration-test` (Runs integration tests)
-  `verify` (Performs additional checks like quality gates, package verification, etc.)
```
### 6. `maven install` goal:
```t
`validate`: Ensures the project is valid and all information is available.
`compile`: Compiles the source code.
`test-compile`: Compiles the test code.
`test`: Runs the unit tests.
`package`: Packages the compiled code into a distributable format, such as a JAR or WAR.
`integration-test`: If applicable, runs integration tests.
`verify`: Runs any additional checks to verify the project is valid and meets `quality` standards.
`install`: Installs the package into the local Maven repository.
```

### 7: note `pom.xml`

**WAR**
```
A WAR (Web Application Archive) file is typically used for packaging web applications (usually Java EE or Jakarta EE projects). A WAR file contains all the resources (HTML, CSS, JavaScript, etc.) and Java classes that are needed to deploy a web application on a servlet container like Tomcat, JBoss, or Jetty.
```

**JAR**
```
A JAR (Java Archive) file, on the other hand, is usually for standalone Java applications or libraries. It's used when your project doesn’t have a web interface or a need for a servlet container.
```

## II. Maven install
### 1. install maven
```powershell
yum update -y

# Install Amazon Corretto 17 (OpenJDK 17)
rpm --import https://yum.corretto.aws/corretto.key
curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-devel

# Install Maven
MAVEN_VERSION=3.9.5
MAVEN_DIR=/opt/maven

wget https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
mkdir -p $MAVEN_DIR
tar -xvzf apache-maven-$MAVEN_VERSION-bin.tar.gz -C $MAVEN_DIR
ln -s $MAVEN_DIR/apache-maven-$MAVEN_VERSION /opt/maven/latest
ln -s /opt/maven/latest/bin/mvn /usr/bin/mvn

# Verify Maven installation
mvn -version
```

### 2. install maven other maven version
```powershell
#!/usr/bin/env bash

MAVEN_VERSION=3.9.9
MAVEN_DIR=/opt/maven

wget https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -O ~/apache-maven-$MAVEN_VERSION-bin.tar.gz

sudo mkdir -p $MAVEN_DIR
sudo tar -xvzf ~/apache-maven-$MAVEN_VERSION-bin.tar.gz -C $MAVEN_DIR

sudo ln -s $MAVEN_DIR/apache-maven-$MAVEN_VERSION /opt/maven/maven-$MAVEN_VERSION
sudo ln -s /opt/maven/maven-$MAVEN_VERSION/bin/mvn /usr/bin/mvn-$MAVEN_VERSION

# checking command:
mvn-3.9.9 --version

# Apache Maven 3.9.9 (8e8579a9e76f7d015ee5ec7bfcdc97d260186937)
# Maven home: /opt/maven/maven-3.9.9
# Java version: 17.0.12, vendor: Amazon.com Inc., runtime: /usr/lib/jvm/java-17-amazon-corretto.x86_64
# Default locale: en_US, platform encoding: UTF-8
# OS name: "linux", version: "4.14.352-267.564.amzn2.x86_64", arch: "amd64", family: "unix"
```


## III. Maven command:

### step-1: clone the repository with `git`
```powershell
git clone https://github.com/duongdx-kma/vprofile-project.

# project structure
├── ansible
├── files
├── Jenkinsfile
├── logo.png
├── pom.xml
├── README.md
└── src
```

### step-2: `Validate` the project with `maven`
```powershell
# change directory
cd vprofile-project

# command:
mvn validate
```

### step-3: `test` code with `maven test`: this command install all dependence and `target` folder is generated
```powershell
# command:
mvn compile

# result: The `target` folder is generated
├── ansible
├── files
├── Jenkinsfile
├── logo.png
├── pom.xml
├── README.md
├── src
└── target

# to remote target: mvn clean
├── ansible
├── files
├── Jenkinsfile
├── logo.png
├── pom.xml
├── README.md
└── src
```

### step-4: `install` code with `maven install` command:
```powershell
# command:
mvn install

# checking
tree -L 1 target/

# result: check node bellow
├── ansible
├── files
├── Jenkinsfile
├── logo.png
├── pom.xml
├── README.md
├── src
└── target
    ├── ...
    ├── vprofile-v2
    └── vprofile-v2.war
```
**check pom.xml**
```powershell
    <groupId>com.visualpathit</groupId>
    <artifactId>vprofile</artifactId>
    <packaging>war</packaging>
    <version>v2</version>
```
**explanation pom.xml**
```
<groupId>: This represents the organization or group to which the project belongs (like a namespace).
<artifactId>: This is the name of the project or artifact (in your case, vprofile-v2).
<version>: This is the version of your project (in this case, 1.0.0).
<packaging>: This defines the packaging type. If this is set to war, it generates a .war file. If it’s jar, Maven will produce a .jar file.
```


### step-5: check project structure:
```powershell

```

### NOTE-01: clean `maven dependencies`:
```powershell
# command:
rm -rf $HOME/.m2
```
